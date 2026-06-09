INSERT INTO users (user_id, email, password_hash, name)
VALUES
  (1, 'demo@petbase.local', 'dev-password-hash', 'PET BASE Demo User')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO dogs (
  dog_id,
  user_id,
  name,
  breed,
  weight_kg,
  baseline_temp_c,
  heart_risk_mode,
  is_active
)
VALUES
  (1, 1, '보리', 'Maltese', 4.20, 38.10, FALSE, TRUE)
ON CONFLICT (dog_id) DO NOTHING;

INSERT INTO devices (
  device_id,
  user_id,
  model,
  firmware_version,
  last_battery_pct,
  is_active
)
VALUES
  ('dog-001', 1, 'PETBASE-MVP-SIM', 'sim-0.1.0', 82, TRUE)
ON CONFLICT (device_id) DO NOTHING;
