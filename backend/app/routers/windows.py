from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app import services
from app.database import get_db
from app.schemas import MeasurementWindowOut


router = APIRouter(tags=["windows"])


@router.get("/measurements/windows/{dog_id}", response_model=list[MeasurementWindowOut])
def get_measurement_windows(
    dog_id: int,
    limit: int = Query(default=96, ge=1, le=500),
    db: Session = Depends(get_db),
):
    return services.list_measurement_windows(db, dog_id=dog_id, limit=limit)
