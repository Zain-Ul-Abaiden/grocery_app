from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from typing import List

from app.database.connection import get_db
from app.models.cart import Cart
from app.models.product import Product
from app.models.order import Order, OrderItem
from app.schemas.order import OrderCreateRequest, OrderResponse
from app.core.security import get_current_user
from app.models.user import User

router = APIRouter(prefix="/orders", tags=["Orders"])

@router.post("/create", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    payload: OrderCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Checkout API: Converts all items provided in the payload into an Order.
    Checks stock, decrements inventory, and creates the order inside a secure database transaction.
    """
    cart_items = payload.items
    
    if not cart_items:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Your cart is empty. Add products before placing an order."
        )
        
    order_items_to_create = []
    total_price = 0.0
    
    # 2. Process each item, verify stock, and prepare order items
    for item in cart_items:
        # Fetch product
        result = await db.execute(select(Product).where(Product.id == item.product_id))
        product = result.scalars().first()
        
        if not product or not product.is_available:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product with ID '{item.product_id}' is no longer available or does not exist."
            )
            
        if product.stock < item.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Insufficient stock for '{product.name}'. Only {product.stock} available, but you requested {item.quantity} units."
            )
            
        # Deduct stock
        product.stock -= item.quantity
        
        # Calculate price (prefer discount price if active)
        item_price = product.discount_price if product.discount_price is not None else product.price
        subtotal = item_price * item.quantity
        total_price += float(subtotal)
        
        # Prepare OrderItem database record
        order_item = OrderItem(
            product_id=product.id,
            quantity=item.quantity,
            price_at_purchase=item_price
        )
        order_items_to_create.append(order_item)
        
    # 3. Create main Order record
    order = Order(
        user_id=current_user.id,
        total_price=total_price,
        status="pending",
        payment_method="COD",
        delivery_address=payload.delivery_address.strip(),
        contact_phone=payload.contact_phone.strip(),
        items=order_items_to_create
    )
    
    db.add(order)

        
    # Commit transaction (handles all stock reductions, cart clears, and order creations atomically)
    await db.commit()
    
    # Reload order to fully populate relationships
    result = await db.execute(
        select(Order)
        .where(Order.id == order.id)
        .options(
            selectinload(Order.items).selectinload(OrderItem.product)
        )
    )
    order_loaded = result.scalars().first()
    
    # Map raw details for serialization helper
    mapped_items = []
    for o_item in order_loaded.items:
        mapped_items.append({
            "id": o_item.id,
            "product_id": o_item.product_id,
            "product_name": o_item.product.name if o_item.product else "Deleted Product",
            "product_unit": o_item.product.unit if o_item.product else "N/A",
            "quantity": o_item.quantity,
            "price_at_purchase": o_item.price_at_purchase,
            "subtotal": o_item.price_at_purchase * o_item.quantity
        })
        
    response_data = {
        "id": order_loaded.id,
        "user_id": order_loaded.user_id,
        "total_price": order_loaded.total_price,
        "status": order_loaded.status,
        "payment_method": order_loaded.payment_method,
        "delivery_address": order_loaded.delivery_address,
        "contact_phone": order_loaded.contact_phone,
        "created_at": order_loaded.created_at,
        "items": mapped_items
    }
    
    return response_data

@router.get("/my", response_model=List[OrderResponse])
async def my_orders(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get order history for the logged-in user.
    """
    result = await db.execute(
        select(Order)
        .where(Order.user_id == current_user.id)
        .options(selectinload(Order.items).selectinload(OrderItem.product))
        .order_by(Order.created_at.desc())
    )
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

@router.get("/{order_id}", response_model=OrderResponse)
async def get_order_detail(
    order_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retrieve full details of a specific order by ID.
    Enforces user ownership (unless they are an admin).
    """
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
        
    # Security: Verify ownership
    if order.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to view this order"
        )
        
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
