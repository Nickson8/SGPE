from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

# Todas as operações usam SQL explícito (text()), conforme exigido pelo projeto
# (OBS 3: não são aceitos comandos SQL gerados implicitamente por ORM).
# Os nomes de tabela/coluna seguem o esquema em init-scripts/01-create-tables.sql.

_ESPECIE_COLUNAS = (
    "nome_cientifico, nome_comum, grupo_taxonomico, "
    "plano_de_manejo AS plano_manejo, quantidade"
)


async def list_especies(db: AsyncSession) -> list[dict]:
    sql = text(
        f"SELECT {_ESPECIE_COLUNAS} FROM especie ORDER BY nome_comum"
    )
    result = await db.execute(sql)
    return [dict(row) for row in result.mappings().all()]


async def get_especie(db: AsyncSession, nome_cientifico: str) -> dict | None:
    sql = text(
        f"SELECT {_ESPECIE_COLUNAS} FROM especie "
        "WHERE nome_cientifico = :nome_cientifico"
    )
    result = await db.execute(sql, {"nome_cientifico": nome_cientifico})
    row = result.mappings().first()
    return dict(row) if row else None
