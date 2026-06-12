from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings

# Build connection-specific arguments.
#  - SQLite needs check_same_thread=False for concurrent threads.
#  - asyncpg against managed Postgres (Neon) needs SSL enabled explicitly, since the
#    libpq-style `?sslmode=require` query param is stripped from the URL (asyncpg
#    does not understand it). We pass an SSL context instead.
_db_url = settings.async_database_url
if _db_url.startswith("sqlite"):
    _connect_args = {"check_same_thread": False}
elif settings.requires_ssl:
    import ssl as _ssl
    _ssl_ctx = _ssl.create_default_context()
    # Neon's pooler presents a valid cert; keep verification on. If a self-signed
    # host is ever used, these two lines can be relaxed.
    _connect_args = {"ssl": _ssl_ctx}
else:
    _connect_args = {}

# Create database engine
engine = create_async_engine(
    settings.async_database_url,
    echo=False,
    future=True,
    pool_pre_ping=True,  # drop dead pooled connections instead of erroring on stale ones
    connect_args=_connect_args,
)

# Session factory for DB operations
AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False
)

# Declarative base for models
Base = declarative_base()

# Dependency to inject DB session into API paths
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
