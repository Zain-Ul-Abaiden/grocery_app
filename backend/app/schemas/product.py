from datetime import datetime
from decimal import Decimal
from typing import Optional, List
from pydantic import BaseModel, Field

# --- Category Schemas ---
class CategoryBase(BaseModel):
    name: str = Field(..., max_length=100)
    image_url: Optional[str] = Field(None, max_length=500)

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int

    class Config:
        from_attributes = True


# --- Product Schemas ---
class ProductBase(BaseModel):
    name: str = Field(..., max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    price: Decimal = Field(..., ge=0)
    discount_price: Optional[Decimal] = Field(None, ge=0)
    
    # "250 gram", "500 gm", "1 kg", "1 packet", "1 piece"
    unit: str = Field(..., max_length=50, description="Standard weight unit (e.g., 250 gram, 500 gm, 1 kg, 1 packet)")
    stock: int = Field(0, ge=0)
    image_url: Optional[str] = Field(None, max_length=500)
    is_available: bool = True
    is_featured: bool = False

class ProductCreate(ProductBase):
    category_id: int

class ProductUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    category_id: Optional[int] = None
    price: Optional[Decimal] = Field(None, ge=0)
    discount_price: Optional[Decimal] = Field(None, ge=0)
    unit: Optional[str] = Field(None, max_length=50)
    stock: Optional[int] = Field(None, ge=0)
    image_url: Optional[str] = Field(None, max_length=500)
    is_available: Optional[bool] = None
    is_featured: Optional[bool] = None

class ProductResponse(ProductBase):
    id: str
    category_id: int
    created_at: datetime

    class Config:
        from_attributes = True
        
class CategoryWithProductsResponse(CategoryResponse):
    products: List[ProductResponse] = []
