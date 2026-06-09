# PET BASE Backend MVP

이 ZIP은 `PET_BASE_최종개발기준문서_v1.2` 기준의 백엔드 개발 단계 산출물입니다.
AI 판독, 외부 AI API, RAG, LLM 판독은 포함하지 않습니다.

## 포함 범위

- PostgreSQL DDL
- seed.sql
- FastAPI 백엔드
- 규칙 기반 판독엔진
- 10초 주기 모의 센서 전송 스크립트
- 15분 요약 저장 테이블 `measurement_windows`

## 실행 순서

```bash
cd backend
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

macOS/Linux:

```bash
source .venv/bin/activate
```

```bash
pip install -r requirements.txt
createdb pet_base
psql -U postgres -d pet_base -f sql/schema.sql
psql -U postgres -d pet_base -f sql/seed.sql
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

시뮬레이터:

```bash
cd ..
python scripts/simulate_realtime_vitals.py --base-url http://127.0.0.1:8000 --scenario cycle
```
