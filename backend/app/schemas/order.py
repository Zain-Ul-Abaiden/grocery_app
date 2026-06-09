from datetime import datetime
from decimal import Decimal
from typing import List, Optional
from pydantic import BaseModel, Field

class CartItemRequest(BaseModel):
    product_id: str
    quantity: int

class OrderCreateRequest(BaseModel):
    delivery_address: str = Field(..., max_length=500, description="Address where the groceries should be delivered")
    contact_phone: str = Field(..., max_length=20, description="Active phone number for delivery coordination")
    items: List[CartItemRequest] = Field(..., description="List of items in the cart")

class OrderItemResponse(BaseModel):
    id: int
    product_id: Optional[str]
    product_name: Optional[str] = None  # Helper label
    product_unit: Optional[str] = None  # Standard unit details (e.g. 250 gram, 500 gm)
    quantity: int
    price_at_purchase: Decimal
    subtotal: Decimal

    class Config:
        from_attributes = True

class OrderResponse(BaseModel):
    id: str
    user_id: Optional[str]
    total_price: Decimal
    status: str  # pending, confirmed, out_for_delivery, delivered, cancelled
    payment_method: str
    delivery_address: str
    contact_phone: str
    created_at: datetime
    items: List[OrderItemResponse] = []

    class Config:
        from_attributes = True

class OrderStatusUpdateRequest(BaseModel):
    # Enforces strict admin status strings
    status: str = Field(..., description="Status string: pending | confirmed | out_for_delivery | delivered | cancelled")

    @classmethod
    def validate_status(cls, v: str) -> str:
        valid_statuses = ['pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled']
        if v not in valid_statuses:
            raise ValueError(f"Status must be one of {valid_statuses}")
        return v
