import uuid
from sqlalchemy import Column, String, DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from app.database.connection import Base

class User(Base):
    __tablename__ = "users"

    # UUID primary key supporting Postgres and SQLite fallbacks
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=True)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(20), default="user")  # 'user' or 'admin'
    address = Column(String(500), nullable=True)  # saved default delivery address
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "phone": self.phone,
            "role": self.role,
            "address": self.address,
            "created_at": self.created_at
        }
