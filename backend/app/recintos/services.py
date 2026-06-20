from collections.abc import Mapping

from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.recintos.schemas import RecintoCreate

# Todas as operações usam SQL explícito (text()), conforme exigido pelo projeto
# (OBS 3). Os nomes de tabela/coluna seguem init-scripts/01-create-tables.sql.


# --------------------------------------------------------------------------- #
# Exceções de domínio: o service classifica a falha do SGBD e o router as
# traduz em respostas HTTP amigáveis (tratamento de erros do cadastro — item 4a/OBS 6).
# --------------------------------------------------------------------------- #
class RecintoDuplicadoError(Exception):
    """Já existe um recinto com o mesmo código GEFAU (violação de PK)."""


class NomeRecintoJaExisteError(Exception):
    """Já existe um recinto com o mesmo nome (violação de UNIQUE)."""


class CapacidadeInvalidaError(Exception):
    """Capacidade incompatível com o número de animais (violação de CHECK)."""


class ErroBancoDados(Exception):
    """Falha genérica do SGBD ao gravar o recinto."""


def percentual_ocupacao(qnt_animais: int, cap_maxima: int) -> float:
    if not cap_maxima:
        return 0.0
    return round((qnt_animais / cap_maxima) * 100, 1)


def status_ocupacao(percentual: float) -> str:
    if percentual > 100:
        return "critico"
    if percentual >= 75:
        return "alerta"
    return "normal"


def recinto_resumo(r: Mapping) -> dict:
    """Monta o resumo (com indicadores de ocupação) a partir de uma linha do banco."""
    pct = percentual_ocupacao(r["qnt_animais"], r["capacidade_max"])
    return {
        "recinto_gefau": r["recinto_gefau"],
        "nome": r["nome"],
        "capacidade_max": r["capacidade_max"],
        "qnt_animais": r["qnt_animais"],
        "qnt_especies": r["qnt_especies"],
        "percentual_ocupacao": pct,
        "status_ocupacao": status_ocupacao(pct),
    }


async def list_recintos(db: AsyncSession, q: str | None = None) -> list[dict]:
    sql = (
        "SELECT recinto_gefau, nome, capacidade_max, qnt_animais, qnt_especies "
        "FROM recinto"
    )
    params: dict = {}
    if q:
        sql += (
            " WHERE LOWER(nome) LIKE :busca OR LOWER(recinto_gefau) LIKE :busca"
        )
        params["busca"] = f"%{q.lower()}%"
    sql += " ORDER BY nome"

    result = await db.execute(text(sql), params)
    return [recinto_resumo(row) for row in result.mappings().all()]


async def create_recinto(db: AsyncSession, data: RecintoCreate) -> dict:
    """Insere um recinto via SQL explícito, com controle transacional e
    classificação dos erros do SGBD (item 4a / OBS 6)."""
    insert_sql = text(
        "INSERT INTO recinto "
        "(recinto_gefau, nome, capacidade_max, qnt_animais, qnt_especies) "
        "VALUES (:recinto_gefau, :nome, :capacidade_max, 0, 0)"
    )
    params = {
        "recinto_gefau": data.recinto_gefau,
        "nome": data.nome,
        "capacidade_max": data.capacidade_max,
    }

    try:
        await db.execute(insert_sql, params)
        await db.commit()
    except IntegrityError as exc:
        await db.rollback()
        constraint = _constraint_name(exc)
        if constraint == "pk_recinto":
            raise RecintoDuplicadoError() from exc
        if constraint == "uk_recinto_nome":
            raise NomeRecintoJaExisteError() from exc
        if constraint == "ck_recinto_capacidade":
            raise CapacidadeInvalidaError() from exc
        # Qualquer outra violação de integridade não prevista.
        raise ErroBancoDados() from exc
    except Exception as exc:  # erro de conexão/execução do SGBD
        await db.rollback()
        raise ErroBancoDados() from exc

    return await get_recinto_resumo(db, data.recinto_gefau)


def _constraint_name(exc: IntegrityError) -> str | None:
    """Extrai o nome da constraint violada do erro asyncpg subjacente."""
    orig = getattr(exc, "orig", None)
    cause = getattr(orig, "__cause__", None)  # asyncpg.exceptions.*
    return getattr(cause, "constraint_name", None)


async def get_recinto_resumo(db: AsyncSession, recinto_gefau: str) -> dict:
    sql = text(
        "SELECT recinto_gefau, nome, capacidade_max, qnt_animais, qnt_especies "
        "FROM recinto WHERE recinto_gefau = :recinto_gefau"
    )
    row = (await db.execute(sql, {"recinto_gefau": recinto_gefau})).mappings().first()
    return recinto_resumo(row)


async def get_recinto_detalhe(db: AsyncSession, recinto_gefau: str) -> dict | None:
    base = (
        await db.execute(
            text(
                "SELECT recinto_gefau, nome, capacidade_max, qnt_animais, "
                "qnt_especies FROM recinto WHERE recinto_gefau = :recinto_gefau"
            ),
            {"recinto_gefau": recinto_gefau},
        )
    ).mappings().first()
    if base is None:
        return None

    # Animais atualmente alocados (sem data de saída) + espécie.
    atuais = (
        await db.execute(
            text(
                "SELECT a.nro_reg, a.apelido, a.sexo, al.data_entrada, "
                "       e.nome_cientifico, e.nome_comum, e.grupo_taxonomico "
                "FROM alocacao al "
                "  JOIN animal a ON a.nro_reg = al.animal "
                "  JOIN especie e ON e.nome_cientifico = a.especie "
                "WHERE al.recinto = :recinto_gefau AND al.data_saida IS NULL "
                "ORDER BY a.apelido"
            ),
            {"recinto_gefau": recinto_gefau},
        )
    ).mappings().all()

    animais_alocados = [
        {
            "nro_reg": r["nro_reg"],
            "apelido": r["apelido"],
            "especie_nome_comum": r["nome_comum"],
            "sexo": r["sexo"],
            "data_entrada": r["data_entrada"],
        }
        for r in atuais
    ]

    # Espécies presentes (distintas) entre os animais atuais.
    especies_presentes: dict[str, dict] = {}
    for r in atuais:
        especies_presentes.setdefault(
            r["nome_cientifico"],
            {
                "nome_cientifico": r["nome_cientifico"],
                "nome_comum": r["nome_comum"],
                "grupo_taxonomico": r["grupo_taxonomico"],
            },
        )

    # Histórico completo de alocações do recinto (atuais + passadas).
    hist = (
        await db.execute(
            text(
                "SELECT a.nro_reg, a.apelido, e.nome_comum, "
                "       al.data_entrada, al.data_saida, al.motivo_saida "
                "FROM alocacao al "
                "  JOIN animal a ON a.nro_reg = al.animal "
                "  JOIN especie e ON e.nome_cientifico = a.especie "
                "WHERE al.recinto = :recinto_gefau "
                "ORDER BY al.data_entrada DESC"
            ),
            {"recinto_gefau": recinto_gefau},
        )
    ).mappings().all()
    historico = [
        {
            "nro_reg": r["nro_reg"],
            "apelido": r["apelido"],
            "especie_nome_comum": r["nome_comum"],
            "data_entrada": r["data_entrada"],
            "data_saida": r["data_saida"],
            "motivo_saida": r["motivo_saida"],
        }
        for r in hist
    ]

    return {
        **recinto_resumo(base),
        "animais_alocados": animais_alocados,
        "especies_presentes": list(especies_presentes.values()),
        "historico_alocacoes": historico,
    }
