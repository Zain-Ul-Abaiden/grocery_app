# Import all models here so that Alembic's autogenerate can discover them
from app.database.connection import Base
from app.models.user import User
from app.models.product import Category, Product
from app.models.cart import Cart
from app.models.order import Order, OrderItem
