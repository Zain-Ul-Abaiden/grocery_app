from sqlalchemy import Column, String, Integer, ForeignKey, UniqueConstraint, CheckConstraint
from sqlalchemy.orm import relationship
from app.database.connection import Base

class Cart(Base):
    __tablename__ = "carts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(String(36), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    quantity = Column(Integer, default=1, nullable=False)

    user = relationship("User")
    product = relationship("Product")

    __table_args__ = (
        UniqueConstraint('user_id', 'product_id', name='uq_user_product_cart'),
        CheckConstraint('quantity > 0', name='check_quantity_positive'),
    )
