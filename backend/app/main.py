from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routers import dashboard, dogs, vitals, windows


app = FastAPI(
    title="PET BASE API",
    description="반려견을 위한 건강상태 알림 프로그램 PET BASE MVP API",
    version="0.1.0",
)

# MVP 기본값 제안:
# Flutter 앱 로컬 개발 편의를 위해 CORS를 열어 둔다.
# 운영 환경에서는 허용 origin을 제한해야 한다.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    # 개발 편의용.
    # 실제 운영에서는 schema.sql 또는 migration 도구로 관리한다.
    Base.metadata.create_all(bind=engine)


@app.get("/")
def root():
    return {
        "service": "PET BASE API",
        "status": "running",
        "rule": "AI 판독 없이 stable + SQI 통과 데이터만 규칙 기반 판독",
    }


app.include_router(dogs.router)
app.include_router(vitals.router)
app.include_router(dashboard.router)
app.include_router(windows.router)
