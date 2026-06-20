from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.dashboard import services
from app.dashboard.schemas import AnimalEmAlerta, DashboardResponse

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardResponse)
async def get_dashboard(db: AsyncSession = Depends(get_db)):
    return await services.get_dashboard(db)


@router.get("/animais-em-alerta", response_model=list[AnimalEmAlerta])
async def animais_em_alerta(
    especie: list[str] = Query(
        default=[],
        description="Nome(s) científico(s) das espécies escolhidas pelo usuário.",
    ),
    db: AsyncSession = Depends(get_db),
):
    return await services.animais_em_alerta(db, especie)
