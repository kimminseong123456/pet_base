DROP TABLE IF EXISTS measurement_windows;
DROP TABLE IF EXISTS health_records;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS dogs;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  user_id BIGSERIAL PRIMARY KEY,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE dogs (
  dog_id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(user_id),
  name VARCHAR(50) NOT NULL,
  breed VARCHAR(80),
  birth_date DATE,
  weight_kg NUMERIC(5,2) NOT NULL,
  baseline_temp_c NUMERIC(4,2),
  heart_risk_mode BOOLEAN NOT NULL DEFAULT FALSE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE devices (
  device_id VARCHAR(64) PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(user_id),
  model VARCHAR(80),
  firmware_version VARCHAR(40),
  last_battery_pct INTEGER,
  last_seen_at TIMESTAMP,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE health_records (
  record_id BIGSERIAL PRIMARY KEY,
  dog_id BIGINT NOT NULL REFERENCES dogs(dog_id),
  device_id VARCHAR(64) REFERENCES devices(device_id),
  measured_at TIMESTAMP NOT NULL,
  received_at TIMESTAMP NOT NULL DEFAULT now(),
  hr_bpm INTEGER,
  rr_bpm INTEGER,
  temp_est_c NUMERIC(4,2),
  motion_state VARCHAR(20),
  sqi_ppg NUMERIC(4,2),
  sqi_rr NUMERIC(4,2),
  sqi_temp NUMERIC(4,2),
  invalid_reason VARCHAR(30),
  t_score INTEGER,
  p_score INTEGER,
  r_score INTEGER,
  avg_score NUMERIC(4,2),
  final_status VARCHAR(20) NOT NULL,
  red_flag BOOLEAN NOT NULL DEFAULT FALSE,
  alert_required BOOLEAN NOT NULL DEFAULT FALSE,
  raw_payload JSONB,
  CHECK (final_status IN ('NORMAL','INTEREST','CAUTION','DANGER','EMERGENCY','INVALID')),
  CHECK (invalid_reason IS NULL OR invalid_reason IN ('motion','no_contact','unstable','jump','sensor_error'))
);

CREATE INDEX idx_health_records_dog_time
ON health_records(dog_id, measured_at DESC);

CREATE INDEX idx_health_records_status
ON health_records(final_status, measured_at DESC);

-- MVP 기본값 제안:
-- 최종개발기준문서에는 15분 요약 조회와 valid_ratio 70% 기준이 있으나,
-- 별도 테이블 DDL은 제시되어 있지 않다.
-- 이번 요구사항의 "15분 요약 결과 저장"을 만족하기 위해 추가한다.
CREATE TABLE measurement_windows (
  window_id BIGSERIAL PRIMARY KEY,
  dog_id BIGINT NOT NULL REFERENCES dogs(dog_id),
  window_start TIMESTAMP NOT NULL,
  window_end TIMESTAMP NOT NULL,
  total_samples INTEGER NOT NULL DEFAULT 0,
  valid_samples INTEGER NOT NULL DEFAULT 0,
  valid_ratio NUMERIC(5,2) NOT NULL DEFAULT 0,
  avg_hr_bpm NUMERIC(6,2),
  avg_rr_bpm NUMERIC(6,2),
  avg_temp_est_c NUMERIC(4,2),
  avg_score NUMERIC(4,2),
  final_status VARCHAR(20) NOT NULL,
  alert_required BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  CHECK (final_status IN ('NORMAL','INTEREST','CAUTION','DANGER','EMERGENCY','INVALID')),
  UNIQUE (dog_id, window_start)
);

CREATE INDEX idx_measurement_windows_dog_time
ON measurement_windows(dog_id, window_start DESC);
