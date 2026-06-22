from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.animais import services
from app.animais.schemas import AnimalDetalhe, AnimalResumo
from app.core.database import get_db

router = APIRouter(prefix="/api/animais", tags=["animais"])


@router.get("", response_model=list[AnimalResumo])
async def list_animais(
    q: str | None = Query(None, description="Busca por apelido, registro, espécie ou GEFAU"),
    db: AsyncSession = Depends(get_db),
):
    return await services.list_animais(db, q=q)


@router.get("/{nro_reg}", response_model=AnimalDetalhe)
async def get_animal(nro_reg: int, db: AsyncSession = Depends(get_db)):
    detalhe = await services.get_animal_detalhe(db, nro_reg)
    if detalhe is None:
        raise HTTPException(status_code=404, detail="Animal não encontrado")
    return detalhe
