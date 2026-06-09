from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import or_
from typing import List, Optional

from app.database.connection import get_db
from app.models.product import Product, Category
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse
from app.core.security import get_current_admin
from app.models.user import User


router = APIRouter(prefix="/products", tags=["Products"])

@router.get("", response_model=List[ProductResponse])
async def list_products(
    category_id: Optional[int] = Query(None, description="Filter by Category ID"),
    search: Optional[str] = Query(None, description="Search term for product name"),
    db: AsyncSession = Depends(get_db)
):
    """
    List all products. Open to public.
    Supports filtering by Category ID and search terms.
    """
    query = select(Product).where(Product.is_available == True)
    
    if category_id is not None:
        query = query.where(Product.category_id == category_id)
        
    if search:
        search_term = f"%{search.strip()}%"
        query = query.where(Product.name.ilike(search_term))
        
    query = query.order_by(Product.name)
    result = await db.execute(query)
    products = result.scalars().all()
    return products

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(product_id: str, db: AsyncSession = Depends(get_db)):
    """
    Get detailed view of a product by ID.
    """
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return product

@router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    payload: ProductCreate,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Create a new product. Admin only.
    Verifies that the target category exists.
    """
    # Verify Category exists
    cat_result = await db.execute(select(Category).where(Category.id == payload.category_id))
    if not cat_result.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Category with ID {payload.category_id} does not exist"
        )
        
    product = Product(
        category_id=payload.category_id,
        name=payload.name.strip(),
        description=payload.description.strip() if payload.description else None,
        price=payload.price,
        discount_price=payload.discount_price,
        unit=payload.unit.strip(),
        stock=payload.stock,
        image_url=payload.image_url,
        is_available=payload.is_available
    )
    
    db.add(product)
    await db.commit()
    await db.refresh(product)
    return product

@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: str,
    payload: ProductUpdate,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Update a product. Admin only.
    """
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
        
    update_data = payload.model_dump(exclude_unset=True)
    
    if "category_id" in update_data:
        cat_result = await db.execute(select(Category).where(Category.id == update_data["category_id"]))
        if not cat_result.scalars().first():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Category with ID {update_data['category_id']} does not exist"
            )
            
    for key, value in update_data.items():
        if isinstance(value, str):
            value = value.strip()
        setattr(product, key, value)
        
    await db.commit()
    await db.refresh(product)
    return product

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: str,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Delete a product. Admin only.
    """
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
        
    await db.delete(product)
    await db.commit()
    return None
