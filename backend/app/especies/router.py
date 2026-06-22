from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.especies import services
from app.especies.schemas import EspecieResponse

router = APIRouter(prefix="/api/especies", tags=["especies"])


@router.get("", response_model=list[EspecieResponse])
async def list_especies(db: AsyncSession = Depends(get_db)):
    return await services.list_especies(db)


@router.get("/{nome_cientifico}", response_model=EspecieResponse)
async def get_especie(nome_cientifico: str, db: AsyncSession = Depends(get_db)):
    especie = await services.get_especie(db, nome_cientifico)
    if especie is None:
        raise HTTPException(status_code=404, detail="Espécie não encontrada")
    return especie
