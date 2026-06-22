from fastapi import APIRouter
from app.api.v1.auth import router as auth_router
from app.api.v1.categories import router as categories_router
from app.api.v1.products import router as products_router
from app.api.v1.cart import router as cart_router
from app.api.v1.orders import router as orders_router
from app.api.v1.admin import router as admin_router
from app.api.v1.upload import router as upload_router
from app.api.v1.banners import router as banners_router
from app.api.v1.favorites import router as favorites_router
from app.api.v1.home import router as home_router

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(auth_router)
api_router.include_router(categories_router)
api_router.include_router(products_router)
api_router.include_router(cart_router)
api_router.include_router(orders_router)
api_router.include_router(admin_router)
api_router.include_router(upload_router)
api_router.include_router(banners_router)
api_router.include_router(favorites_router)
api_router.include_router(home_router)
