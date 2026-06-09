from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.database.connection import get_db
from app.models.product import Category
from app.schemas.product import CategoryCreate, CategoryResponse
from app.core.security import get_current_admin
from app.models.user import User


router = APIRouter(prefix="/categories", tags=["Categories"])

@router.get("", response_model=List[CategoryResponse])
async def list_categories(db: AsyncSession = Depends(get_db)):
    """
    Get all product categories. Open to public.
    """
    result = await db.execute(select(Category).order_by(Category.name))
    categories = result.scalars().all()
    return categories

@router.post("", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
async def create_category(
    payload: CategoryCreate, 
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Create a new product category. Admin only.
    """
    # Check if category name already exists
    result = await db.execute(select(Category).where(Category.name == payload.name.strip()))
    existing = result.scalars().first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Category with this name already exists"
        )
        
    category = Category(
        name=payload.name.strip(),
        image_url=payload.image_url
    )
    db.add(category)
    await db.commit()
    await db.refresh(category)
    return category

@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_category(
    category_id: int, 
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Delete a category. Admin only.
    """
    result = await db.execute(select(Category).where(Category.id == category_id))
    category = result.scalars().first()
    
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
        
    await db.delete(category)
    await db.commit()
    return None
