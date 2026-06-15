from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

class UserLoginRequest(BaseModel):
    phone: str = Field(..., description="Phone number of the user", example="+923001234567")
    password: str = Field(..., description="Password of the user")

class UserSignupRequest(BaseModel):
    phone: str = Field(..., description="Phone number of the user", example="+923001234567")
    name: str = Field(..., description="Name of the user", example="Zainab")
    password: str = Field(..., description="Password of the user")

class UserResponse(BaseModel):
    id: str
    phone: str
    name: Optional[str]
    role: str
    address: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
