from __future__ import annotations

from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Optional

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models
from app.rule_engine import (
    DogContext,
    PreviousRecordContext,
    RecentScoreContext,
    VALID_RATIO_15M_TH,
    evaluate_vitals,
    get_status_text,
    is_alert_required,
)
from app.schemas import DevSeedIn, DogCreate, DogUpdate, VitalIngest


def _naive_utc(dt: datetime) -> datetime:
    if dt.tzinfo is None:
        return dt
    return dt.astimezone(timezone.utc).replace(tzinfo=None)


def _to_float(value) -> Optional[float]:
    if value is None:
        return None
    if isinstance(value, Decimal):
        return float(value)
    return float(value)


def _status_rank(status: str) -> int:
    ranks = {
        "NORMAL": 0,
        "INTEREST": 1,
        "CAUTION": 2,
        "DANGER": 3,
        "EMERGENCY": 4,
        "INVALID": -1,
    }
    return ranks.get(status, -1)


def _floor_15m(dt: datetime) -> datetime:
    dt = _naive_utc(dt)
    minute = (dt.minute // 15) * 15
    return dt.replace(minute=minute, second=0, microsecond=0)


def ensure_demo_user(db: Session) -> models.User:
    user = db.get(models.User, 1)
    if user is None:
        user = models.User(
            user_id=1,
            email="demo@petbase.local",
            password_hash="dev-password-hash",
            name="PET BASE Demo User",
        )
        db.add(user)
        db.flush()
    return user


def dev_seed(db: Session, payload: DevSeedIn) -> tuple[models.Dog, models.Device]:
    user = ensure_demo_user(db)

    dog = db.get(models.Dog, 1)
    if dog is None:
        dog = models.Dog(
            dog_id=1,
            user_id=user.user_id,
            name=payload.dog_name,
            breed=payload.breed,
            weight_kg=payload.weight_kg,
            baseline_temp_c=payload.baseline_temp_c,
            heart_risk_mode=False,
            is_active=True,
        )
        db.add(dog)
    else:
        dog.name = payload.dog_name
        dog.breed = payload.breed
        dog.weight_kg = payload.weight_kg
        dog.baseline_temp_c = payload.baseline_temp_c

    device = db.get(models.Device, payload.device_id)
    if device is None:
        device = models.Device(
            device_id=payload.device_id,
            user_id=user.user_id,
            model="PETBASE-MVP-SIM",
            firmware_version=payload.firmware_version,
            last_battery_pct=82,
            is_active=True,
        )
        db.add(device)
    else:
        device.firmware_version = payload.firmware_version
        device.is_active = True

    db.commit()
    db.refresh(dog)
    db.refresh(device)
    return dog, device


def list_dogs(db: Session) -> list[models.Dog]:
    stmt = select(models.Dog).order_by(models.Dog.dog_id.asc())
    return list(db.scalars(stmt).all())


def create_dog(db: Session, payload: DogCreate) -> models.Dog:
    user = db.get(models.User, payload.user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="user not found")

    dog = models.Dog(
        user_id=payload.user_id,
        name=payload.name,
        breed=payload.breed,
        birth_date=payload.birth_date,
        weight_kg=payload.weight_kg,
        baseline_temp_c=payload.baseline_temp_c,
        heart_risk_mode=payload.heart_risk_mode,
        is_active=True,
    )
    db.add(dog)
    db.commit()
    db.refresh(dog)
    return dog


def update_dog(db: Session, dog_id: int, payload: DogUpdate) -> models.Dog:
    dog = db.get(models.Dog, dog_id)
    if dog is None:
        raise HTTPException(status_code=404, detail="dog not found")

    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(dog, key, value)

    db.commit()
    db.refresh(dog)
    return dog


def _ensure_device_for_packet(db: Session, dog: models.Dog, payload: VitalIngest) -> models.Device:
    device = db.get(models.Device, payload.device_id)
    if device is None:
        device = models.Device(
            device_id=payload.device_id,
            user_id=dog.user_id,
            model="PETBASE-MVP-SIM",
            firmware_version="sim-unknown",
            is_active=True,
        )
        db.add(device)

    device.last_battery_pct = payload.battery_pct
    device.last_seen_at = _naive_utc(payload.ts)
    return device


def _get_previous_record_context(
    db: Session,
    dog_id: int,
) -> Optional[PreviousRecordContext]:
    stmt = (
        select(models.HealthRecord)
        .where(models.HealthRecord.dog_id == dog_id)
        .order_by(models.HealthRecord.measured_at.desc())
        .limit(1)
    )
    record = db.scalars(stmt).first()
    if record is None:
        return None

    return PreviousRecordContext(
        measured_at=record.measured_at,
        hr_bpm=record.hr_bpm,
        rr_bpm=record.rr_bpm,
        temp_est_c=_to_float(record.temp_est_c),
    )


def _get_recent_valid_scores(
    db: Session,
    dog_id: int,
    limit: int = 3,
) -> list[RecentScoreContext]:
    stmt = (
        select(models.HealthRecord)
        .where(
            models.HealthRecord.dog_id == dog_id,
            models.HealthRecord.final_status != "INVALID",
        )
        .order_by(models.HealthRecord.measured_at.desc())
        .limit(limit)
    )
    records = list(db.scalars(stmt).all())

    return [
        RecentScoreContext(
            t_score=record.t_score,
            p_score=record.p_score,
            r_score=record.r_score,
            final_status=record.final_status,
        )
        for record in records
    ]


def ingest_vitals(db: Session, payload: VitalIngest) -> models.HealthRecord:
    dog = db.get(models.Dog, payload.dog_id)
    if dog is None:
        raise HTTPException(status_code=404, detail="dog not found")

    device = _ensure_device_for_packet(db, dog, payload)

    previous = _get_previous_record_context(db, dog.dog_id)
    recent_scores = _get_recent_valid_scores(db, dog.dog_id)

    dog_context = DogContext(
        dog_id=dog.dog_id,
        weight_kg=float(dog.weight_kg),
        baseline_temp_c=_to_float(dog.baseline_temp_c),
        heart_risk_mode=dog.heart_risk_mode,
    )

    result = evaluate_vitals(
        packet=payload,
        dog=dog_context,
        previous=previous,
        recent_scores=recent_scores,
    )

    record = models.HealthRecord(
        dog_id=dog.dog_id,
        device_id=device.device_id,
        measured_at=_naive_utc(payload.ts),
        hr_bpm=payload.hr_bpm,
        rr_bpm=payload.rr_bpm,
        temp_est_c=payload.temp_est_c,
        motion_state=payload.motion_state,
        sqi_ppg=payload.sqi_ppg,
        sqi_rr=payload.sqi_rr,
        sqi_temp=payload.sqi_temp,
        invalid_reason=result.invalid_reason,
        t_score=result.t_score,
        p_score=result.p_score,
        r_score=result.r_score,
        avg_score=result.avg_score,
        final_status=result.final_status,
        red_flag=payload.red_flag,
        alert_required=result.alert_required,
        raw_payload=payload.model_dump(mode="json"),
    )

    db.add(record)
    db.flush()

    upsert_measurement_window(db, dog.dog_id, record.measured_at)

    db.commit()
    db.refresh(record)
    return record


def get_latest_record(db: Session, dog_id: int) -> Optional[models.HealthRecord]:
    stmt = (
        select(models.HealthRecord)
        .where(models.HealthRecord.dog_id == dog_id)
        .order_by(models.HealthRecord.measured_at.desc())
        .limit(1)
    )
    return db.scalars(stmt).first()


def get_dashboard(db: Session, dog_id: int) -> dict:
    dog = db.get(models.Dog, dog_id)
    if dog is None:
        raise HTTPException(status_code=404, detail="dog not found")

    record = get_latest_record(db, dog_id)
    if record is None:
        headline, _ = get_status_text("INVALID", "sensor_error")
        return {
            "dog_id": dog.dog_id,
            "dog_name": dog.name,
            "final_status": "INVALID",
            "headline": headline,
            "message": "아직 수신된 측정값이 없습니다.",
            "hr_bpm": None,
            "rr_bpm": None,
            "temp_est_c": None,
            "sqi_ppg": None,
            "sqi_rr": None,
            "sqi_temp": None,
            "invalid_reason": "sensor_error",
            "measured_at": None,
            "alert_required": False,
        }

    headline, message = get_status_text(record.final_status, record.invalid_reason)
    return {
        "dog_id": dog.dog_id,
        "dog_name": dog.name,
        "final_status": record.final_status,
        "headline": headline,
        "message": message,
        "hr_bpm": record.hr_bpm,
        "rr_bpm": record.rr_bpm,
        "temp_est_c": _to_float(record.temp_est_c),
        "sqi_ppg": _to_float(record.sqi_ppg),
        "sqi_rr": _to_float(record.sqi_rr),
        "sqi_temp": _to_float(record.sqi_temp),
        "invalid_reason": record.invalid_reason,
        "measured_at": record.measured_at,
        "alert_required": record.alert_required,
    }


def _summary_status_from_records(records: list[models.HealthRecord], valid_ratio: float) -> str:
    if valid_ratio < VALID_RATIO_15M_TH:
        return "INVALID"

    valid_records = [record for record in records if record.final_status != "INVALID"]
    if not valid_records:
        return "INVALID"

    # MVP 기본값 제안:
    # 문서에는 15분 윈도우의 최종 상태 산출 방식이 상세히 고정되어 있지 않다.
    # 안전 우선으로 윈도우 내 가장 높은 심각도 상태를 요약 상태로 저장한다.
    return max(valid_records, key=lambda item: _status_rank(item.final_status)).final_status


def upsert_measurement_window(
    db: Session,
    dog_id: int,
    measured_at: datetime,
) -> models.MeasurementWindow:
    window_start = _floor_15m(measured_at)
    window_end = window_start + timedelta(minutes=15)

    stmt = select(models.HealthRecord).where(
        models.HealthRecord.dog_id == dog_id,
        models.HealthRecord.measured_at >= window_start,
        models.HealthRecord.measured_at < window_end,
    )
    records = list(db.scalars(stmt).all())

    total_samples = len(records)
    valid_records = [record for record in records if record.final_status != "INVALID"]
    valid_samples = len(valid_records)
    valid_ratio = round(valid_samples / total_samples, 2) if total_samples > 0 else 0.0

    final_status = _summary_status_from_records(records, valid_ratio)
    alert_required = is_alert_required(final_status)

    def avg(values: list[float]) -> Optional[float]:
        clean = [value for value in values if value is not None]
        if not clean:
            return None
        return round(sum(clean) / len(clean), 2)

    window = db.scalars(
        select(models.MeasurementWindow).where(
            models.MeasurementWindow.dog_id == dog_id,
            models.MeasurementWindow.window_start == window_start,
        )
    ).first()

    if window is None:
        window = models.MeasurementWindow(
            dog_id=dog_id,
            window_start=window_start,
            window_end=window_end,
        )
        db.add(window)

    window.total_samples = total_samples
    window.valid_samples = valid_samples
    window.valid_ratio = valid_ratio
    window.avg_hr_bpm = avg([record.hr_bpm for record in valid_records])
    window.avg_rr_bpm = avg([record.rr_bpm for record in valid_records])
    window.avg_temp_est_c = avg([_to_float(record.temp_est_c) for record in valid_records])
    window.avg_score = avg([_to_float(record.avg_score) for record in valid_records])
    window.final_status = final_status
    window.alert_required = alert_required

    db.flush()
    return window


def list_measurement_windows(
    db: Session,
    dog_id: int,
    limit: int = 96,
) -> list[models.MeasurementWindow]:
    dog = db.get(models.Dog, dog_id)
    if dog is None:
        raise HTTPException(status_code=404, detail="dog not found")

    stmt = (
        select(models.MeasurementWindow)
        .where(models.MeasurementWindow.dog_id == dog_id)
        .order_by(models.MeasurementWindow.window_start.desc())
        .limit(limit)
    )
    return list(db.scalars(stmt).all())
