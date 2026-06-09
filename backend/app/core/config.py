import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    PROJECT_NAME: str = "Production Grocery API"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "super_secret_key_change_me_in_production_1234567890")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 Days token

    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "postgresql+asyncpg://postgres:postgres@localhost:5432/grocery_db" 
    )

    @property
    def async_database_url(self) -> str:
        # Neon or other platforms give "postgres://" URL. SQLAlchemy requires "postgresql+asyncpg://"
        url = self.DATABASE_URL
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql+asyncpg://", 1)
        elif url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url

settings = Settings()
