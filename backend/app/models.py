from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    user_id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(120), nullable=False, unique=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    name: Mapped[str | None] = mapped_column(String(50), nullable=True)
    created_at = mapped_column(DateTime, nullable=False, server_default=func.now())

    dogs = relationship("Dog", back_populates="user")
    devices = relationship("Device", back_populates="user")


class Dog(Base):
    __tablename__ = "dogs"

    dog_id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("users.user_id"), nullable=False)

    name: Mapped[str] = mapped_column(String(50), nullable=False)
    breed: Mapped[str | None] = mapped_column(String(80), nullable=True)
    birth_date = mapped_column(Date, nullable=True)
    weight_kg = mapped_column(Numeric(5, 2), nullable=False)
    baseline_temp_c = mapped_column(Numeric(4, 2), nullable=True)

    heart_risk_mode: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at = mapped_column(DateTime, nullable=False, server_default=func.now())

    user = relationship("User", back_populates="dogs")
    health_records = relationship("HealthRecord", back_populates="dog")
    measurement_windows = relationship("MeasurementWindow", back_populates="dog")


class Device(Base):
    __tablename__ = "devices"

    device_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("users.user_id"), nullable=False)

    model: Mapped[str | None] = mapped_column(String(80), nullable=True)
    firmware_version: Mapped[str | None] = mapped_column(String(40), nullable=True)
    last_battery_pct: Mapped[int | None] = mapped_column(Integer, nullable=True)
    last_seen_at = mapped_column(DateTime, nullable=True)

    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at = mapped_column(DateTime, nullable=False, server_default=func.now())

    user = relationship("User", back_populates="devices")


class HealthRecord(Base):
    __tablename__ = "health_records"

    __table_args__ = (
        CheckConstraint(
            "final_status IN ('NORMAL','INTEREST','CAUTION','DANGER','EMERGENCY','INVALID')",
            name="ck_health_records_final_status",
        ),
        CheckConstraint(
            "invalid_reason IS NULL OR invalid_reason IN "
            "('motion','no_contact','unstable','jump','sensor_error')",
            name="ck_health_records_invalid_reason",
        ),
    )

    record_id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)

    dog_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("dogs.dog_id"), nullable=False)
    device_id: Mapped[str | None] = mapped_column(String(64), ForeignKey("devices.device_id"), nullable=True)

    measured_at = mapped_column(DateTime, nullable=False)
    received_at = mapped_column(DateTime, nullable=False, server_default=func.now())

    hr_bpm: Mapped[int | None] = mapped_column(Integer, nullable=True)
    rr_bpm: Mapped[int | None] = mapped_column(Integer, nullable=True)
    temp_est_c = mapped_column(Numeric(4, 2), nullable=True)

    motion_state: Mapped[str | None] = mapped_column(String(20), nullable=True)
    sqi_ppg = mapped_column(Numeric(4, 2), nullable=True)
    sqi_rr = mapped_column(Numeric(4, 2), nullable=True)
    sqi_temp = mapped_column(Numeric(4, 2), nullable=True)

    invalid_reason: Mapped[str | None] = mapped_column(String(30), nullable=True)

    t_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    p_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    r_score: Mapped[int | None] = mapped_column(Integer, nullable=True)
    avg_score = mapped_column(Numeric(4, 2), nullable=True)

    final_status: Mapped[str] = mapped_column(String(20), nullable=False)
    red_flag: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    alert_required: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    raw_payload = mapped_column(JSONB, nullable=True)

    dog = relationship("Dog", back_populates="health_records")


class MeasurementWindow(Base):
    __tablename__ = "measurement_windows"

    __table_args__ = (
        UniqueConstraint("dog_id", "window_start", name="uq_measurement_windows_dog_start"),
        CheckConstraint(
            "final_status IN ('NORMAL','INTEREST','CAUTION','DANGER','EMERGENCY','INVALID')",
            name="ck_measurement_windows_final_status",
        ),
    )

    window_id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    dog_id: Mapped[int] = mapped_column(BigInteger, ForeignKey("dogs.dog_id"), nullable=False)

    window_start = mapped_column(DateTime, nullable=False)
    window_end = mapped_column(DateTime, nullable=False)

    total_samples: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    valid_samples: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    valid_ratio = mapped_column(Numeric(5, 2), nullable=False, default=0)

    avg_hr_bpm = mapped_column(Numeric(6, 2), nullable=True)
    avg_rr_bpm = mapped_column(Numeric(6, 2), nullable=True)
    avg_temp_est_c = mapped_column(Numeric(4, 2), nullable=True)
    avg_score = mapped_column(Numeric(4, 2), nullable=True)

    final_status: Mapped[str] = mapped_column(String(20), nullable=False)
    alert_required: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    created_at = mapped_column(DateTime, nullable=False, server_default=func.now())
    updated_at = mapped_column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    dog = relationship("Dog", back_populates="measurement_windows")
