from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from app.database.connection import Base

class Banner(Base):
    __tablename__ = "banners"

    id = Column(Integer, primary_key=True, index=True)
    image_url = Column(String(500), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
