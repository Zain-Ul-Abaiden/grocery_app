from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.connection import get_db
from app.models.user import User
from app.schemas.user import UserLoginRequest, UserSignupRequest, TokenResponse, UserResponse
from app.core.security import create_access_token, get_current_user, hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["Authentication"])

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
