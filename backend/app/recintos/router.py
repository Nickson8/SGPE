from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.recintos import services
from app.recintos.schemas import RecintoDetalhe, RecintoResumo

router = APIRouter(prefix="/api/recintos", tags=["recintos"])


@router.get("", response_model=list[RecintoResumo])
async def list_recintos(
    q: str | None = Query(None, description="Busca por nome ou código GEFAU"),
    db: AsyncSession = Depends(get_db),
):
    return await services.list_recintos(db, q=q)


@router.get("/{recinto_gefau}", response_model=RecintoDetalhe)
async def get_recinto(recinto_gefau: str, db: AsyncSession = Depends(get_db)):
    detalhe = await services.get_recinto_detalhe(db, recinto_gefau)
    if detalhe is None:
        raise HTTPException(status_code=404, detail="Recinto não encontrado")
    return detalhe
