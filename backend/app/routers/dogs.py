from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import services
from app.database import get_db
from app.schemas import DevSeedIn, DevSeedOut, DogCreate, DogOut, DogUpdate


router = APIRouter(tags=["dogs"])


@router.post("/dev/seed", response_model=DevSeedOut)
def dev_seed(payload: DevSeedIn, db: Session = Depends(get_db)):
    dog, device = services.dev_seed(db, payload)
    return DevSeedOut(
        user_id=dog.user_id,
        dog_id=dog.dog_id,
        device_id=device.device_id,
        message="seed data created or updated",
    )


@router.get("/dogs", response_model=list[DogOut])
def list_dogs(db: Session = Depends(get_db)):
    return services.list_dogs(db)


@router.post("/dogs", response_model=DogOut)
def create_dog(payload: DogCreate, db: Session = Depends(get_db)):
    return services.create_dog(db, payload)


@router.patch("/dogs/{dog_id}", response_model=DogOut)
def update_dog(dog_id: int, payload: DogUpdate, db: Session = Depends(get_db)):
    return services.update_dog(db, dog_id, payload)
