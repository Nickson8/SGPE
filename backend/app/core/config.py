from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Conexão somente leitura com o Postgres provisionado pelos init-scripts.
    DATABASE_URL: str = "postgresql+asyncpg://sgpe:sgpe@postgres:5432/sgpe_db"
    # Origem do frontend Vite (CORS).
    FRONTEND_ORIGIN: str = "http://localhost:5173"

    model_config = {"env_file": ".env", "extra": "ignore"}


settings = Settings()
