from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint, DateTime, func
from sqlalchemy.orm import relationship
from app.database.connection import Base

class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(String(36), ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User")
    product = relationship("Product")

    __table_args__ = (
        UniqueConstraint('user_id', 'product_id', name='uq_user_product_favorite'),
    )
