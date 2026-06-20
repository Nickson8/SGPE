from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.animais.router import router as animais_router
from app.core.config import settings
from app.dashboard.router import router as dashboard_router
from app.especies.router import router as especies_router
from app.recintos.router import router as recintos_router

app = FastAPI(
    title="SGPE API",
    description="API do Sistema de Gestão para Parques Ecológicos (somente leitura).",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.FRONTEND_ORIGIN],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(dashboard_router)
app.include_router(especies_router)
app.include_router(animais_router)
app.include_router(recintos_router)


@app.get("/api/health")
async def health_check():
    return {"status": "ok"}
