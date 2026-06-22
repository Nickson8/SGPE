from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

# O esquema é criado pelos scripts em init-scripts/ na subida do Postgres.
# Aqui apenas conectamos para CONSULTAR — nunca usamos create_all/migrations.
engine = create_async_engine(settings.DATABASE_URL, pool_size=10, max_overflow=5)

async_session = async_sessionmaker(engine, expire_on_commit=False)


class Base(DeclarativeBase):
    """Base declarativa usada somente para MAPEAR tabelas existentes."""


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session
