from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database.connection import get_db
from app.models.cart import Cart
from app.models.product import Product
from app.schemas.cart import CartAddRequest, CartUpdateRequest, CartSummaryResponse, CartItemResponse
from app.core.security import get_current_user
from app.models.user import User

router = APIRouter(prefix="/cart", tags=["Shopping Cart"])

@router.get("", response_model=CartSummaryResponse)
async def get_cart(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """
    Get user's shopping cart items and calculated pricing summary.
    Applies discount price if available.
    """
    # Fetch cart items joined with product details
    result = await db.execute(
        select(Cart)
        .where(Cart.user_id == current_user.id)
        .options(selectinload(Cart.product))
    )
    cart_items = result.scalars().all()
    
    response_items = []
    total_price = 0.0
    
    for item in cart_items:
        product = item.product
        if not product or not product.is_available:
            continue
            
        # Determine actual price to use (discount vs standard)
        unit_price = product.discount_price if product.discount_price is not None else product.price
        subtotal = unit_price * item.quantity
        total_price += float(subtotal)
        
        response_items.append({
            "id": item.id,
            "product": product,
            "quantity": item.quantity,
            "subtotal": subtotal
        })
        
    return {
        "items": response_items,
        "total_price": total_price
    }

@router.post("/add", response_model=CartItemResponse)
async def add_to_cart(
    payload: CartAddRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Add a product to the user's cart or increment its quantity if it already exists.
    Checks product availability and stock limits.
    """
    # Verify product exists and is available
    prod_result = await db.execute(select(Product).where(Product.id == payload.product_id))
    product = prod_result.scalars().first()
    
    if not product or not product.is_available:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product is not available for purchase"
        )
        
    # Check if cart item already exists for this user and product
    cart_result = await db.execute(
        select(Cart)
        .where(Cart.user_id == current_user.id, Cart.product_id == payload.product_id)
        .options(selectinload(Cart.product))
    )
    cart_item = cart_result.scalars().first()
    
    if cart_item:
        new_qty = cart_item.quantity + payload.quantity
        if new_qty > product.stock:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot add requested quantity. Only {product.stock} items available in stock."
            )
        cart_item.quantity = new_qty
    else:
        if payload.quantity > product.stock:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Cannot add requested quantity. Only {product.stock} items available in stock."
            )
        cart_item = Cart(
            user_id=current_user.id,
            product_id=payload.product_id,
            quantity=payload.quantity
        )
        db.add(cart_item)
        await db.flush()  # Populates id
        
    await db.commit()
    
    # Reload to ensure products mapping is fully loaded
    await db.refresh(cart_item, ["product"])
    
    unit_price = product.discount_price if product.discount_price is not None else product.price
    subtotal = unit_price * cart_item.quantity
    
    return {
        "id": cart_item.id,
        "product": cart_item.product,
        "quantity": cart_item.quantity,
        "subtotal": subtotal
    }

@router.put("/{cart_id}", response_model=CartItemResponse)
async def update_cart_quantity(
    cart_id: int,
    payload: CartUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update the quantity of a specific cart item by ID.
    Checks stock limits.
    """
    result = await db.execute(
        select(Cart)
        .where(Cart.id == cart_id, Cart.user_id == current_user.id)
        .options(selectinload(Cart.product))
    )
    cart_item = result.scalars().first()
    
    if not cart_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cart item not found"
        )
        
    product = cart_item.product
    if payload.quantity > product.stock:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot update quantity. Only {product.stock} items available in stock."
        )
        
    cart_item.quantity = payload.quantity
    await db.commit()
    await db.refresh(cart_item)
    
    unit_price = product.discount_price if product.discount_price is not None else product.price
    subtotal = unit_price * cart_item.quantity
    
    return {
        "id": cart_item.id,
        "product": product,
        "quantity": cart_item.quantity,
        "subtotal": subtotal
    }

@router.delete("/remove/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_from_cart(
    product_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Remove a specific product completely from the user's cart.
    """
    result = await db.execute(
        select(Cart).where(Cart.user_id == current_user.id, Cart.product_id == product_id)
    )
    cart_item = result.scalars().first()
    
    if not cart_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found in cart"
        )
        
    await db.delete(cart_item)
    await db.commit()
    return None

@router.delete("/clear", status_code=status.HTTP_204_NO_CONTENT)
async def clear_cart(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    """
    Remove all items from the user's shopping cart.
    """
    result = await db.execute(select(Cart).where(Cart.user_id == current_user.id))
    cart_items = result.scalars().all()
    
    for item in cart_items:
        await db.delete(item)
        
    await db.commit()
    return None
