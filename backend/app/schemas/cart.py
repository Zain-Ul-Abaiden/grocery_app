from decimal import Decimal
from pydantic import BaseModel, Field
from app.schemas.product import ProductResponse

class CartAddRequest(BaseModel):
    product_id: str
    quantity: int = Field(1, ge=1, description="Quantity of the specified unit to add")

class CartUpdateRequest(BaseModel):
    quantity: int = Field(..., ge=1, description="New quantity to set")

class CartItemResponse(BaseModel):
    id: int
    product: ProductResponse
    quantity: int
    subtotal: Decimal

    class Config:
        from_attributes = True

class CartSummaryResponse(BaseModel):
    items: list[CartItemResponse]
    total_price: Decimal
