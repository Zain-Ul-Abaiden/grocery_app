from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.future import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.api.router import api_router
from app.database.connection import engine, Base, AsyncSessionLocal
from app.models.product import Category, Product
from app.models.user import User
from app.core.security import hash_password

app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Set up CORS middleware to support all client calls (including Flutter web/desktop/mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include master API router
app.include_router(api_router)

# Mount static files for local uploads
import os
os.makedirs("uploads", exist_ok=True)
app.mount("/static/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/", tags=["Root"])
def read_root():
    return {
        "message": "Welcome to the Production Grocery Store API!",
        "documentation": "/docs",
        "status": "online"
    }

async def seed_data(db: AsyncSession):
    """
    Automated seed helper. Inserts SabziMarket.online categories, products with metric sizes,
    and a default admin profile on initial startup if the database is empty.
    """
    # 1. Seed Categories if empty
    result = await db.execute(select(Category))
    if not result.scalars().first():
        # Create Categories based on SabziMarket Online
        oil = Category(name="Cooking Oil", image_url="https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5")
        flour = Category(name="Flour (Aata)", image_url="https://images.unsplash.com/photo-1574316071802-0d684efa7bf5")
        daal = Category(name="Daal", image_url="https://images.unsplash.com/photo-1547058886-f13693952aab")
        spices = Category(name="Spices", image_url="https://images.unsplash.com/photo-1596790011462-8430396f9755")
        snacks = Category(name="Snacks & Beverages", image_url="https://images.unsplash.com/photo-1599490659213-e2b9527bb087")
        tea = Category(name="Tea & Coffee", image_url="https://images.unsplash.com/photo-1517256064527-09c53b2d0c6b")
        milk = Category(name="Packed Milk & Milk Powder", image_url="https://images.unsplash.com/photo-1563636619-e9143da7973b")
        frozen = Category(name="Frozen Food", image_url="https://images.unsplash.com/photo-1560684352-8497838a2229")
        
        db.add_all([oil, flour, daal, spices, snacks, tea, milk, frozen])
        await db.flush()  # Populates IDs
        
        # 2. Seed Products with standard metric units and exact packaging sizes
        products = [
            # --- Cooking Oil ---
            Product(
                category_id=oil.id,
                name="Areesa Cooking pouch Oil 1x5",
                description="Premium healthy cooking pouch oil packs.",
                price=2049.00,
                discount_price=1950.00,
                unit="1x5 pouch",
                stock=40,
                image_url="https://images.unsplash.com/photo-1622484211148-7163a3cbf3ff"
            ),
            Product(
                category_id=oil.id,
                name="Dalda Cooking Oil Pouch 1x5",
                description="Original Dalda high-quality cooking oil pouch packets.",
                price=2999.00,
                discount_price=2890.00,
                unit="1x5 pouch",
                stock=35,
                image_url="https://images.unsplash.com/photo-1622484211148-7163a3cbf3ff"
            ),
            Product(
                category_id=oil.id,
                name="Pure Cooking Oil Pouch 1x5",
                description="100% pure cooking oil pouch pack.",
                price=2599.00,
                discount_price=None,
                unit="1x5 pouch",
                stock=25,
                image_url="https://images.unsplash.com/photo-1622484211148-7163a3cbf3ff"
            ),
            Product(
                category_id=oil.id,
                name="Soya Supreme Cooking Oil Pouch 1x5",
                description="Soya Supreme double refined cooking oil pouch.",
                price=2880.00,
                discount_price=2750.00,
                unit="1x5 pouch",
                stock=20,
                image_url="https://images.unsplash.com/photo-1622484211148-7163a3cbf3ff"
            ),
            
            # --- Daal ---
            Product(
                category_id=daal.id,
                name="Beson (500gram Half kg)",
                description="Pure chana dal beson for cooking snacks.",
                price=180.00,
                discount_price=165.00,
                unit="500 gram",
                stock=60,
                image_url="https://images.unsplash.com/photo-1547058886-f13693952aab"
            ),
            Product(
                category_id=daal.id,
                name="Black Channa (500gram Half kg)",
                description="High grade black gram chickpeas.",
                price=170.00,
                discount_price=None,
                unit="500 gram",
                stock=80,
                image_url="https://images.unsplash.com/photo-1547058886-f13693952aab"
            ),
            Product(
                category_id=daal.id,
                name="Daal Channa (Half kg 500gram)",
                description="Premium polished yellow chana dal.",
                price=170.00,
                discount_price=155.00,
                unit="500 gram",
                stock=75,
                image_url="https://images.unsplash.com/photo-1547058886-f13693952aab"
            ),
            
            # --- Frozen Food ---
            Product(
                category_id=frozen.id,
                name="Aloo Cutlets (12pcs)",
                description="Crispy potato potato patties ready to fry. Home made style.",
                price=699.00,
                discount_price=649.00,
                unit="12 pieces",
                stock=30,
                image_url="https://images.unsplash.com/photo-1560684352-8497838a2229"
            ),
            Product(
                category_id=frozen.id,
                name="Aloo Keema Cutlets (12pcs)",
                description="Spicy beef and potato blended cutlets.",
                price=695.00,
                discount_price=None,
                unit="12 pieces",
                stock=25,
                image_url="https://images.unsplash.com/photo-1560684352-8497838a2229"
            ),
            Product(
                category_id=frozen.id,
                name="Beef Kofta (12pcs)",
                description="Juicy pre-cooked tender beef meatballs.",
                price=850.00,
                discount_price=799.00,
                unit="12 pieces",
                stock=15,
                image_url="https://images.unsplash.com/photo-1560684352-8497838a2229"
            ),
            Product(
                category_id=frozen.id,
                name="Beef Shami kabab (12pcs)",
                description="Authentic spices traditional beef shami kababs.",
                price=799.00,
                discount_price=740.00,
                unit="12 pieces",
                stock=45,
                image_url="https://images.unsplash.com/photo-1560684352-8497838a2229"
            ),
            Product(
                category_id=frozen.id,
                name="Chicken Box Patties (12pcs)",
                description="Crispy square pockets filled with hot chicken cheese.",
                price=895.00,
                discount_price=None,
                unit="12 pieces",
                stock=18,
                image_url="https://images.unsplash.com/photo-1560684352-8497838a2229"
            ),
            Product(
                category_id=frozen.id,
                name="Chicken Chinese Rolls (12pcs)",
                description="Crispy snack rolls packed with chicken and mixed veggies.",
                price=895.00,
                discount_price=850.00,
                unit="12 pieces",
                stock=20,
                image_url="https://images.unsplash.com/photo-1560684352-8497838a2229"
            )
        ]
        db.add_all(products)
        
        # 3. Seed Default Admin
        admin_user = User(
            phone="+923001234567",
            name="Zain",
            hashed_password=hash_password("admin123"),  # generated at seed time so it always verifies
            role="admin"
        )
        db.add(admin_user)
        await db.commit()
        print("Database successfully seeded with SabziMarket online grocery data!")





@app.on_event("startup")
async def startup_event():
    # Automatically generate tables on start (essential for easy SQLite local run)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        
    # Seed mock data
    async with AsyncSessionLocal() as session:
        await seed_data(session)
