from fastapi import APIRouter, Depends
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import func
from typing import List
from pydantic import BaseModel

from app.database.connection import get_db
from app.models.product import Product, Category
from app.models.order import OrderItem
from app.models.banner import Banner
from app.schemas.product import ProductResponse, CategoryResponse
from app.api.v1.banners import BannerResponse

router = APIRouter(prefix="/home", tags=["Home"])

# Number of products surfaced per rail / per category section
RAIL_LIMIT = 10


class CategorySection(BaseModel):
    category: CategoryResponse
    products: List[ProductResponse]


class HomeResponse(BaseModel):
    banners: List[BannerResponse]
    categories: List[CategoryResponse]
    bestsellers: List[ProductResponse]
    featured: List[ProductResponse]
    deals: List[ProductResponse]
    category_sections: List[CategorySection]


@router.get("", response_model=HomeResponse)
async def get_home_feed(db: AsyncSession = Depends(get_db)):
    """
    Composed home feed for the mobile app. Returns everything the home screen
    needs in a single round-trip: banners, categories, top sellers, featured,
    deals, and a horizontal carousel per category.
    """
    # --- Banners (active only) ---
    banners_result = await db.execute(select(Banner).where(Banner.is_active == True))
    banners = banners_result.scalars().all()

    # --- Categories ---
    categories_result = await db.execute(select(Category).order_by(Category.name))
    categories = categories_result.scalars().all()

    # --- Bestsellers: top products by total quantity sold ---
    bestsellers_result = await db.execute(
        select(Product)
        .join(OrderItem, OrderItem.product_id == Product.id)
        .where(Product.is_available == True)
        .group_by(Product.id)
        .order_by(func.sum(OrderItem.quantity).desc())
        .limit(RAIL_LIMIT)
    )
    bestsellers = bestsellers_result.scalars().all()

    # Fallback when there are no orders yet: show newest available products
    if not bestsellers:
        fallback_result = await db.execute(
            select(Product)
            .where(Product.is_available == True)
            .order_by(Product.created_at.desc())
            .limit(RAIL_LIMIT)
        )
        bestsellers = fallback_result.scalars().all()

    # --- Featured (admin-curated) ---
    featured_result = await db.execute(
        select(Product)
        .where(Product.is_featured == True, Product.is_available == True)
        .order_by(Product.created_at.desc())
        .limit(RAIL_LIMIT)
    )
    featured = featured_result.scalars().all()

    # --- Deals (any product with an active discount price) ---
    deals_result = await db.execute(
        select(Product)
        .where(Product.discount_price.isnot(None), Product.is_available == True)
        .order_by(Product.created_at.desc())
        .limit(RAIL_LIMIT)
    )
    deals = deals_result.scalars().all()

    # --- Per-category carousels (omit empty categories) ---
    category_sections = []
    for category in categories:
        section_result = await db.execute(
            select(Product)
            .where(Product.category_id == category.id, Product.is_available == True)
            .order_by(Product.name)
            .limit(RAIL_LIMIT)
        )
        section_products = section_result.scalars().all()
        if section_products:
            category_sections.append(
                CategorySection(category=category, products=section_products)
            )

    return HomeResponse(
        banners=banners,
        categories=categories,
        bestsellers=bestsellers,
        featured=featured,
        deals=deals,
        category_sections=category_sections,
    )
