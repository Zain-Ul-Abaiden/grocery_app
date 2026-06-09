import uuid
from sqlalchemy import Column, String, Integer, Numeric, ForeignKey, DateTime, func, CheckConstraint
from sqlalchemy.orm import relationship
from app.database.connection import Base

class Order(Base):
    __tablename__ = "orders"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    total_price = Column(Numeric(precision=10, scale=2), nullable=False)
    
    # Status options: 'pending', 'confirmed', 'out_for_delivery', 'delivered', 'cancelled'
    status = Column(String(30), default="pending", nullable=False)
    payment_method = Column(String(30), default="COD", nullable=False)
    
    delivery_address = Column(String(500), nullable=False)
    contact_phone = Column(String(20), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(String(36), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(String(36), ForeignKey("products.id", ondelete="SET NULL"), nullable=True)
    quantity = Column(Integer, nullable=False)
    
    # Store price at purchase to ensure receipts are locked even if the shopkeeper modifies product base prices later
    price_at_purchase = Column(Numeric(precision=10, scale=2), nullable=False)

    order = relationship("Order", back_populates="items")
    product = relationship("Product")

    __table_args__ = (
        CheckConstraint('quantity > 0', name='check_order_quantity_positive'),
        CheckConstraint('price_at_purchase >= 0', name='check_purchase_price_positive'),
    )
