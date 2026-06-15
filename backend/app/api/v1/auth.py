from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.future import select
from sqlalchemy import delete, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.connection import get_db
from app.models.user import User
from app.models.cart import Cart
from app.models.favorite import Favorite
from app.models.order import Order
from app.schemas.user import UserLoginRequest, UserSignupRequest, TokenResponse, UserResponse
from app.core.security import create_access_token, get_current_user, hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["Authentication"])


class UpdatePasswordRequest(BaseModel):
    new_password: str = Field(..., min_length=6, description="New password (min 6 chars)")


class ForgotPasswordRequest(BaseModel):
    phone: str = Field(..., description="Registered phone number")
    new_password: str = Field(..., min_length=6, description="New password (min 6 chars)")


class UpdateProfileRequest(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = Field(None, max_length=500)

@router.post("/signup", response_model=TokenResponse)
async def signup(payload: UserSignupRequest, db: AsyncSession = Depends(get_db)):
    phone_clean = payload.phone.strip()
    result = await db.execute(select(User).where(User.phone == phone_clean))
    existing_user = result.scalars().first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered"
        )
        
    user = User(
        phone=phone_clean,
        name=payload.name.strip(),
        hashed_password=hash_password(payload.password),
        role="user"
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    
    access_token = create_access_token(data={"sub": user.id, "role": user.role})
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.post("/login", response_model=TokenResponse)
async def login(payload: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    """
    Login with phone and password.
    """
    phone_clean = payload.phone.strip()
    
    result = await db.execute(select(User).where(User.phone == phone_clean))
    user = result.scalars().first()
    
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or password"
        )
        
    access_token = create_access_token(data={"sub": user.id, "role": user.role})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user
    }

@router.get("/me", response_model=UserResponse)
async def get_my_profile(current_user: User = Depends(get_current_user)):
    """
    Retrieve currently logged in user profile.
    """
    return current_user


@router.post("/update-password", response_model=UserResponse)
async def update_password(
    payload: UpdatePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update the logged-in user's password directly (no old password required).
    """
    current_user.hashed_password = hash_password(payload.new_password)
    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.post("/update-profile", response_model=UserResponse)
async def update_profile(
    payload: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Update the logged-in user's name and/or saved delivery address.
    """
    if payload.name is not None:
        current_user.name = payload.name.strip()
    if payload.address is not None:
        current_user.address = payload.address.strip()
    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_account(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Permanently delete the logged-in user's account.
    Cleans up cart & favorites, detaches past orders, then removes the user.
    """
    await db.execute(delete(Cart).where(Cart.user_id == current_user.id))
    await db.execute(delete(Favorite).where(Favorite.user_id == current_user.id))
    # Keep order history but detach it from the deleted user
    await db.execute(update(Order).where(Order.user_id == current_user.id).values(user_id=None))
    await db.delete(current_user)
    await db.commit()
    return None


@router.post("/forgot-password", response_model=UserResponse)
async def forgot_password(payload: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    """
    Reset a password by phone number (no OTP — simple flow for this app).
    Looks up the user by phone and sets the new password.
    """
    result = await db.execute(select(User).where(User.phone == payload.phone.strip()))
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No account found with this phone number",
        )
    user.hashed_password = hash_password(payload.new_password)
    await db.commit()
    await db.refresh(user)
    return user

@router.post("/make-admin", response_model=UserResponse)
async def make_user_admin(phone: str, admin_secret: str = None, db: AsyncSession = Depends(get_db)):
    """
    Utility route to elevate a user to 'admin' role.
    To prevent random abuse, you can match a basic query secret or simply elevate.
    """
    if admin_secret != "grocery_admin_key_123":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid secret key to promote admin"
        )
        
    result = await db.execute(select(User).where(User.phone == phone.strip()))
    user = result.scalars().first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
        
    user.role = "admin"
    await db.commit()
    await db.refresh(user)
    return user
