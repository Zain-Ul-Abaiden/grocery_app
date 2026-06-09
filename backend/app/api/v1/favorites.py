from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from pydantic import BaseModel

from app.database.connection import get_db
from app.models.favorite import Favorite
from app.models.product import Product
from app.schemas.product import ProductResponse
from app.core.security import get_current_user
from app.models.user import User
from sqlalchemy.orm import selectinload

router = APIRouter(prefix="/favorites", tags=["Favorites"])

class FavoriteRequest(BaseModel):
    product_id: str

@router.get("", response_model=List[ProductResponse])
async def list_favorites(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all favorite products for the current user.
    """
    result = await db.execute(
        select(Favorite)
        .where(Favorite.user_id == current_user.id)
        .options(selectinload(Favorite.product))
    )
    favorites = result.scalars().all()
    # Return just the products
    return [fav.product for fav in favorites if fav.product]

@router.post("", status_code=status.HTTP_201_CREATED)
async def add_favorite(
    payload: FavoriteRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Add a product to favorites.
    """
    # Check if product exists
    prod_res = await db.execute(select(Product).where(Product.id == payload.product_id))
    if not prod_res.scalars().first():
        raise HTTPException(status_code=404, detail="Product not found")
        
    # Check if already favorited
    fav_res = await db.execute(
        select(Favorite).where(
            Favorite.user_id == current_user.id,
            Favorite.product_id == payload.product_id
        )
    )
    if fav_res.scalars().first():
        return {"message": "Already in favorites"}
        
    fav = Favorite(user_id=current_user.id, product_id=payload.product_id)
    db.add(fav)
    await db.commit()
    return {"message": "Added to favorites"}

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_favorite(
    product_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Remove a product from favorites.
    """
    fav_res = await db.execute(
        select(Favorite).where(
            Favorite.user_id == current_user.id,
            Favorite.product_id == product_id
        )
    )
    fav = fav_res.scalars().first()
    if fav:
        await db.delete(fav)
        await db.commit()
    return None
