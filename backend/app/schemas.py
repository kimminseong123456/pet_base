from datetime import date, datetime
from typing import Literal, Optional

from pydantic import BaseModel, ConfigDict, Field


InvalidReason = Literal["motion", "no_contact", "unstable", "jump", "sensor_error"]
FinalStatus = Literal["NORMAL", "INTEREST", "CAUTION", "DANGER", "EMERGENCY", "INVALID"]
MotionState = Literal["stable", "moving", "unknown"]

# MVP 기본값 제안:
# 문서 의사코드에는 resp_pattern이 등장하지만,
# MQTT vitals payload 예시에는 없다.
# 응급 호흡 패턴 테스트를 위해 선택 필드로만 둔다.
RespPattern = Literal["normal", "open_mouth", "abdominal", "cyanosis"]


class DogCreate(BaseModel):
    # MVP 기본값 제안:
    # 문서에는 인증 API가 없으므로 demo user_id=1을 기본값으로 둔다.
    user_id: int = 1
    name: str = Field(min_length=1, max_length=50)
    breed: Optional[str] = Field(default=None, max_length=80)
    birth_date: Optional[date] = None
    weight_kg: float = Field(gt=0, le=100)
    baseline_temp_c: Optional[float] = Field(default=None, ge=30.0, le=45.0)
    heart_risk_mode: bool = False


class DogUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=50)
    breed: Optional[str] = Field(default=None, max_length=80)
    birth_date: Optional[date] = None
    weight_kg: Optional[float] = Field(default=None, gt=0, le=100)
    baseline_temp_c: Optional[float] = Field(default=None, ge=30.0, le=45.0)
    heart_risk_mode: Optional[bool] = None
    is_active: Optional[bool] = None


class DogOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    dog_id: int
    user_id: int
    name: str
    breed: Optional[str]
    birth_date: Optional[date]
    weight_kg: float
    baseline_temp_c: Optional[float]
    heart_risk_mode: bool
    is_active: bool


class DevSeedIn(BaseModel):
    dog_name: str = "보리"
    breed: str = "Maltese"
    weight_kg: float = 4.2
    baseline_temp_c: Optional[float] = 38.1
    device_id: str = "dog-001"
    firmware_version: str = "sim-0.1.0"


class DevSeedOut(BaseModel):
    user_id: int
    dog_id: int
    device_id: str
    message: str


class VitalIngest(BaseModel):
    ts: datetime
    device_id: str
    dog_id: int

    hr_bpm: Optional[int] = Field(default=None, ge=0, le=260)
    rr_bpm: Optional[int] = Field(default=None, ge=0, le=120)
    temp_est_c: Optional[float] = Field(default=None, ge=25.0, le=45.0)

    motion_state: MotionState = "unknown"

    sqi_ppg: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    sqi_rr: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    sqi_temp: Optional[float] = Field(default=None, ge=0.0, le=1.0)

    invalid_reason: Optional[InvalidReason] = None
    battery_pct: Optional[int] = Field(default=None, ge=0, le=100)
    red_flag: bool = False

    resp_pattern: Optional[RespPattern] = None


class ScoresOut(BaseModel):
    t_score: Optional[int]
    p_score: Optional[int]
    r_score: Optional[int]
    avg_score: Optional[float]


class VitalIngestOut(BaseModel):
    record_id: int
    dog_id: int
    final_status: FinalStatus
    invalid_reason: Optional[InvalidReason]
    alert_required: bool
    measured_at: datetime
    headline: str
    scores: ScoresOut


class HealthRecordOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    record_id: int
    dog_id: int
    device_id: Optional[str]
    measured_at: datetime

    hr_bpm: Optional[int]
    rr_bpm: Optional[int]
    temp_est_c: Optional[float]

    motion_state: Optional[str]
    sqi_ppg: Optional[float]
    sqi_rr: Optional[float]
    sqi_temp: Optional[float]

    invalid_reason: Optional[str]
    t_score: Optional[int]
    p_score: Optional[int]
    r_score: Optional[int]
    avg_score: Optional[float]

    final_status: FinalStatus
    red_flag: bool
    alert_required: bool


class DashboardOut(BaseModel):
    dog_id: int
    dog_name: str
    final_status: FinalStatus
    headline: str
    message: str

    hr_bpm: Optional[int]
    rr_bpm: Optional[int]
    temp_est_c: Optional[float]

    sqi_ppg: Optional[float]
    sqi_rr: Optional[float]
    sqi_temp: Optional[float]

    invalid_reason: Optional[InvalidReason]
    measured_at: Optional[datetime]
    alert_required: bool

    disclaimer: str = "본 결과는 웨어러블 생체신호 기반의 추정 안내이며 진단이 아닙니다."


class MeasurementWindowOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    window_id: int
    dog_id: int
    window_start: datetime
    window_end: datetime

    total_samples: int
    valid_samples: int
    valid_ratio: float

    avg_hr_bpm: Optional[float]
    avg_rr_bpm: Optional[float]
    avg_temp_est_c: Optional[float]
    avg_score: Optional[float]

    final_status: FinalStatus
    alert_required: bool
