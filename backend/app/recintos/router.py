from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.recintos import services
from app.recintos.schemas import RecintoCreate, RecintoDetalhe, RecintoResumo
from app.recintos.services import (
    CapacidadeInvalidaError,
    ErroBancoDados,
    NomeRecintoJaExisteError,
    RecintoDuplicadoError,
)

router = APIRouter(prefix="/api/recintos", tags=["recintos"])


@router.get("", response_model=list[RecintoResumo])
async def list_recintos(
    q: str | None = None,
    db: AsyncSession = Depends(get_db),
):
    return await services.list_recintos(db, q=q)


@router.post("", status_code=201, response_model=RecintoResumo)
async def criar_recinto(data: RecintoCreate, db: AsyncSession = Depends(get_db)):
    try:
        return await services.create_recinto(db, data)
    except RecintoDuplicadoError:
        raise HTTPException(
            status_code=409,
            detail=f"Já existe um recinto com o código GEFAU '{data.recinto_gefau}'.",
        )
    except NomeRecintoJaExisteError:
        raise HTTPException(
            status_code=409,
            detail=f"Já existe um recinto com o nome '{data.nome}'.",
        )
    except CapacidadeInvalidaError:
        raise HTTPException(
            status_code=422,
            detail="Capacidade máxima inválida para este recinto.",
        )
    except ErroBancoDados:
        raise HTTPException(
            status_code=503,
            detail="Não foi possível salvar o recinto no momento. Tente novamente.",
        )


@router.get("/{recinto_gefau}", response_model=RecintoDetalhe)
async def get_recinto(recinto_gefau: str, db: AsyncSession = Depends(get_db)):
    detalhe = await services.get_recinto_detalhe(db, recinto_gefau)
    if detalhe is None:
        raise HTTPException(status_code=404, detail="Recinto não encontrado")
    return detalhe
