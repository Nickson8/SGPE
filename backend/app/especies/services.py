from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.especies.models import Especie


async def list_especies(db: AsyncSession) -> list[Especie]:
    result = await db.execute(select(Especie).order_by(Especie.nome_comum))
    return list(result.scalars().all())


async def get_especie(db: AsyncSession, nome_cientifico: str) -> Especie | None:
    return await db.get(Especie, nome_cientifico)
