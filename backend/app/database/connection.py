from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings

# Create database engine
engine = create_async_engine(
    settings.async_database_url,
    echo=False,
    future=True,
    # SQLite requires some special arguments to handle concurrent threads safely
    connect_args={"check_same_thread": False} if settings.async_database_url.startswith("sqlite") else {}
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
