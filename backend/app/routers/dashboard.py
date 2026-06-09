from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import services
from app.database import get_db
from app.schemas import DashboardOut


router = APIRouter(tags=["dashboard"])


@router.get("/dashboard/{dog_id}", response_model=DashboardOut)
def get_dashboard(dog_id: int, db: Session = Depends(get_db)):
    return services.get_dashboard(db, dog_id)
