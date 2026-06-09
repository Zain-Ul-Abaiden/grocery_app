import uuid
from sqlalchemy import Column, String, Integer, Numeric, Boolean, ForeignKey, DateTime, func, CheckConstraint
from sqlalchemy.orm import relationship
from app.database.connection import Base

class Category(Base):
    __tablename__ = "categories"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, index=True, nullable=False)
    image_url = Column(String(500), nullable=True)

    products = relationship("Product", back_populates="category", cascade="all, delete-orphan")


class Product(Base):
    __tablename__ = "products"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(200), index=True, nullable=False)
    description = Column(String(1000), nullable=True)
    
    # Store price as Decimal/Numeric for accuracy in financial transactions
    price = Column(Numeric(precision=10, scale=2), nullable=False)
    discount_price = Column(Numeric(precision=10, scale=2), nullable=True)
    
    # Standard metric weights: "250 gram", "500 gm", "1 kg", "1 packet", "1 piece"
    unit = Column(String(50), nullable=False)
    
    stock = Column(Integer, default=0, nullable=False)
    image_url = Column(String(500), nullable=True)
    is_available = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    category = relationship("Category", back_populates="products")

    __table_args__ = (
        CheckConstraint('stock >= 0', name='check_stock_positive'),
        CheckConstraint('price >= 0', name='check_price_positive'),
    )
