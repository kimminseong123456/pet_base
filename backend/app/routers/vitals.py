from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import services
from app.database import get_db
from app.rule_engine import get_status_text
from app.schemas import HealthRecordOut, ScoresOut, VitalIngest, VitalIngestOut


router = APIRouter(tags=["vitals"])


@router.post("/ingest/vitals", response_model=VitalIngestOut)
def ingest_vitals(payload: VitalIngest, db: Session = Depends(get_db)):
    record = services.ingest_vitals(db, payload)
    headline, _ = get_status_text(record.final_status, record.invalid_reason)

    return VitalIngestOut(
        record_id=record.record_id,
        dog_id=record.dog_id,
        final_status=record.final_status,
        invalid_reason=record.invalid_reason,
        alert_required=record.alert_required,
        measured_at=record.measured_at,
        headline=headline,
        scores=ScoresOut(
            t_score=record.t_score,
            p_score=record.p_score,
            r_score=record.r_score,
            avg_score=float(record.avg_score) if record.avg_score is not None else None,
        ),
    )


@router.get("/measurements/latest/{dog_id}", response_model=HealthRecordOut)
def get_latest_measurement(dog_id: int, db: Session = Depends(get_db)):
    record = services.get_latest_record(db, dog_id)
    if record is None:
        raise HTTPException(status_code=404, detail="latest measurement not found")
    return record
