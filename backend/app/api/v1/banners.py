from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.database.connection import get_db
from app.models.banner import Banner
from pydantic import BaseModel
from app.core.security import get_current_admin
from app.models.user import User

router = APIRouter(prefix="/banners", tags=["Banners"])

class BannerCreate(BaseModel):
    image_url: str
    is_active: bool = True

class BannerResponse(BaseModel):
    id: int
    image_url: str
    is_active: bool

    class Config:
        from_attributes = True

@router.get("", response_model=List[BannerResponse])
async def list_banners(db: AsyncSession = Depends(get_db)):
    """
    Get all active banners for the mobile app home screen.
    """
    result = await db.execute(select(Banner).where(Banner.is_active == True))
    return result.scalars().all()

@router.post("", response_model=BannerResponse, status_code=status.HTTP_201_CREATED)
async def create_banner(
    payload: BannerCreate, 
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    banner = Banner(
        image_url=payload.image_url,
        is_active=payload.is_active
    )
    db.add(banner)
    await db.commit()
    await db.refresh(banner)
    return banner

@router.delete("/{banner_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_banner(
    banner_id: int, 
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    result = await db.execute(select(Banner).where(Banner.id == banner_id))
    banner = result.scalars().first()
    if not banner:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Banner not found")
        
    await db.delete(banner)
    await db.commit()
    return None
