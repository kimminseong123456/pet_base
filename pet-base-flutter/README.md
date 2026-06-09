# PET BASE Flutter MVP

이 Flutter 앱은 `PET_BASE_최종개발기준문서_v1.2`와 앞 단계 FastAPI 백엔드를 기준으로 만든 PET BASE 앱 MVP이다.

## 핵심 기준

- 앱 화면은 FastAPI 서버값만 표시한다.
- 하드코딩 fallback 센서값은 사용하지 않는다.
- 상태는 NORMAL / INTEREST / CAUTION / DANGER / EMERGENCY / INVALID를 표시한다.
- INVALID는 건강 등급이 아니라 `측정불가` 시스템 상태로 표시한다.
- 체온은 반드시 `체온 추정`으로 표시한다.
- 위험 / 응급은 사용자가 끌 수 없는 고정 ON 알림 상태로 표현한다.
- 실제 푸시 알림은 구현하지 않고 `alert_required` 값에 따라 UI 경고 배너를 표시한다.
- 기록 화면은 `/measurements/windows/{dog_id}`의 15분 고정 윈도우 결과를 표시한다.

## 폴더 구조

```text
pet-base-flutter/
  pubspec.yaml
  lib/
    main.dart
    models/
      dog.dart
      dashboard.dart
      measurement.dart
    services/
      api_service.dart
    screens/
      dashboard_screen.dart
      history_screen.dart
      dog_profile_screen.dart
      notification_settings_screen.dart
    widgets/
      status_card.dart
      metric_card.dart
      invalid_reason_card.dart
      trend_summary_card.dart
  firmware/
    pet_base_mqtt_sender/
      pet_base_mqtt_sender.ino
```

## FastAPI 서버 주소 설정

PC에서 Flutter를 실행할 때:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

실제 안드로이드 기기에서 실행할 때:

```bash
flutter run --dart-define=API_BASE_URL=http://내_PC_IP:8000
```

예시:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.45.235:8000
```

## 실행 순서

1. PostgreSQL 실행
2. FastAPI 서버 실행

```bash
cd C:\Users\k4172\Desktop\pet-base-backend\backend
.\.venv\Scripts\activate.bat
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

3. 시뮬레이터 실행

```bash
cd C:\Users\k4172\Desktop\pet-base-backend
backend\.venv\Scripts\activate.bat
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario cycle
```

4. Flutter 앱 실행

```bash
cd pet-base-flutter
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## 상태 테스트

시뮬레이터를 각각 실행해 대시보드 상태를 확인한다.

```bash
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario normal
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario interest
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario caution
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario danger
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario emergency
python scripts\simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario invalid
```

## ESP32 MQTT 송신 골격

`firmware/pet_base_mqtt_sender/pet_base_mqtt_sender.ino`는 실제 센서값 대신 mock 값을 publish한다.

- `/device/{id}/vitals`
- `/device/{id}/event`

실제 센서 검증, MAX30102/TMP117/BMI270 연결, SQI 계산, Wi-Fi 품질, MQTT broker 연동은 실제 부품 연결 후 검증 필요.
