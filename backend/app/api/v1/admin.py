from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import func
from sqlalchemy.orm import selectinload
from typing import List, Optional

from app.database.connection import get_db
from app.models.order import Order, OrderItem
from app.models.user import User
from app.models.product import Product
from app.schemas.order import OrderResponse, OrderStatusUpdateRequest
from app.core.security import get_current_admin

router = APIRouter(prefix="/admin", tags=["Admin Control Panel"])

@router.get("/dashboard")
async def get_dashboard_stats(
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Get core metrics for admin dashboard. Restricted to Admin.
    Calculates total revenue, total orders count, pending orders, and total users.
    """
    # 1. Total revenue (sum of delivered orders)
    rev_result = await db.execute(
        select(func.sum(Order.total_price)).where(Order.status == "delivered")
    )
    total_revenue = rev_result.scalar() or 0.0
    
    # 2. Total orders count
    orders_cnt_result = await db.execute(select(func.count(Order.id)))
    total_orders = orders_cnt_result.scalar() or 0
    
    # 3. Pending orders count
    pending_cnt_result = await db.execute(
        select(func.count(Order.id)).where(Order.status == "pending")
    )
    pending_orders = pending_cnt_result.scalar() or 0
    
    # 4. Total users count (excluding admin)
    users_cnt_result = await db.execute(
        select(func.count(User.id)).where(User.role == "user")
    )
    total_users = users_cnt_result.scalar() or 0
    
    # 5. Out of stock products
    out_of_stock_result = await db.execute(
        select(func.count(Product.id)).where(Product.stock == 0)
    )
    out_of_stock_products = out_of_stock_result.scalar() or 0
    
    return {
        "stats": {
            "total_revenue": float(total_revenue),
            "total_orders": total_orders,
            "pending_orders": pending_orders,
            "total_users": total_users,
            "out_of_stock_products": out_of_stock_products
        }
    }

@router.get("/orders", response_model=List[OrderResponse])
async def list_all_orders(
    status: Optional[str] = Query(None, description="Filter orders by status"),
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Master list of all grocery orders in the system. Admin only.
    """
    query = select(Order).options(selectinload(Order.items).selectinload(OrderItem.product))
    
    if status:
        query = query.where(Order.status == status.strip())
        
    query = query.order_by(Order.created_at.desc())
    result = await db.execute(query)
    orders = result.scalars().all()
    
    mapped_orders = []
    for order in orders:
        mapped_items = []
        for o_item in order.items:
            mapped_items.append({
                "id": o_item.id,
                "product_id": o_item.product_id,
                "product_name": o_item.product.name if o_item.product else "Deleted Product",
                "product_unit": o_item.product.unit if o_item.product else "N/A",
                "quantity": o_item.quantity,
                "price_at_purchase": o_item.price_at_purchase,
                "subtotal": o_item.price_at_purchase * o_item.quantity
            })
        mapped_orders.append({
            "id": order.id,
            "user_id": order.user_id,
            "total_price": order.total_price,
            "status": order.status,
            "payment_method": order.payment_method,
            "delivery_address": order.delivery_address,
            "contact_phone": order.contact_phone,
            "created_at": order.created_at,
            "items": mapped_items
        })
        
    return mapped_orders

@router.put("/orders/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: str,
    payload: OrderStatusUpdateRequest,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_admin)
):
    """
    Update status of an order (e.g. confirming, dispatching, or delivering). Admin only.
    """
    # Enforce strict value checks
    valid_statuses = ['pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled']
    status_clean = payload.status.strip().lower()
    if status_clean not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status value. Must be one of {valid_statuses}"
        )
        
    result = await db.execute(
        select(Order)
        .where(Order.id == order_id)
        .options(selectinload(Order.items).selectinload(OrderItem.product))
    )
    order = result.scalars().first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
        
    order.status = status_clean
    await db.commit()
    await db.refresh(order)
    
    mapped_items = []
    for o_item in order.items:
        mapped_items.append({
            "id": o_item.id,
            "product_id": o_item.product_id,
            "product_name": o_item.product.name if o_item.product else "Deleted Product",
            "product_unit": o_item.product.unit if o_item.product else "N/A",
            "quantity": o_item.quantity,
            "price_at_purchase": o_item.price_at_purchase,
            "subtotal": o_item.price_at_purchase * o_item.quantity
        })
        
    return {
        "id": order.id,
        "user_id": order.user_id,
        "total_price": order.total_price,
        "status": order.status,
        "payment_method": order.payment_method,
        "delivery_address": order.delivery_address,
        "contact_phone": order.contact_phone,
        "created_at": order.created_at,
        "items": mapped_items
    }
