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

        # asyncpg does NOT understand libpq query params like `sslmode` / `channel_binding`
        # (those are psycopg2/libpq syntax). Strip the query string here and let the
        # engine handle SSL via connect_args instead. See `requires_ssl`.
        if url.startswith("postgresql+asyncpg://") and "?" in url:
            url = url.split("?", 1)[0]
        return url

    @property
    def requires_ssl(self) -> bool:
        # Managed Postgres (Neon, Supabase, RDS, etc.) requires SSL. Detect from the
        # original URL's query string or a hosted-provider hostname.
        raw = self.DATABASE_URL.lower()
        if "sslmode=require" in raw or "sslmode=verify" in raw:
            return True
        # Neon / common managed hosts always need SSL.
        return any(host in raw for host in ("neon.tech", "supabase", "amazonaws.com", "render.com"))

settings = Settings()
