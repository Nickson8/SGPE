from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.especies.models import Especie
from app.animais.models import Animal
from app.recintos.models import Alocacao, Recinto
from app.recintos.schemas import RecintoCreate


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


def recinto_resumo(r: Recinto) -> dict:
    pct = percentual_ocupacao(r.qnt_animais, r.capacidade_max)
    return {
        "recinto_gefau": r.recinto_gefau,
        "nome": r.nome,
        "capacidade_max": r.capacidade_max,
        "qnt_animais": r.qnt_animais,
        "qnt_especies": r.qnt_especies,
        "percentual_ocupacao": pct,
        "status_ocupacao": status_ocupacao(pct),
    }


async def list_recintos(db: AsyncSession, q: str | None = None) -> list[dict]:
    stmt = select(Recinto).order_by(Recinto.nome)
    if q:
        like = f"%{q.lower()}%"
        stmt = stmt.where(
            (Recinto.nome.ilike(like)) | (Recinto.recinto_gefau.ilike(like))
        )
    result = await db.execute(stmt)
    return [recinto_resumo(r) for r in result.scalars().all()]


async def create_recinto(db: AsyncSession, data: RecintoCreate) -> dict:
    obj = Recinto(
        recinto_gefau=data.recinto_gefau,
        nome=data.nome,
        capacidade_max=data.capacidade_max,
        qnt_animais=0,
        qnt_especies=0,
    )
    db.add(obj)
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        raise
    await db.refresh(obj)
    return recinto_resumo(obj)


async def get_recinto_detalhe(db: AsyncSession, recinto_gefau: str) -> dict | None:
    recinto = await db.get(Recinto, recinto_gefau)
    if recinto is None:
        return None

    # Animais atualmente alocados (sem data de saída) + espécie.
    atuais_stmt = (
        select(Alocacao, Animal, Especie)
        .join(Animal, Animal.nro_reg == Alocacao.animal)
        .join(Especie, Especie.nome_cientifico == Animal.especie)
        .where(Alocacao.recinto == recinto_gefau, Alocacao.data_saida.is_(None))
        .order_by(Animal.apelido)
    )
    atuais = (await db.execute(atuais_stmt)).all()

    animais_alocados = [
        {
            "nro_reg": animal.nro_reg,
            "apelido": animal.apelido,
            "especie_nome_comum": especie.nome_comum,
            "sexo": animal.sexo,
            "data_entrada": aloc.data_entrada,
        }
        for aloc, animal, especie in atuais
    ]

    # Espécies presentes (distintas) entre os animais atuais.
    especies_presentes: dict[str, dict] = {}
    for _aloc, _animal, especie in atuais:
        especies_presentes.setdefault(
            especie.nome_cientifico,
            {
                "nome_cientifico": especie.nome_cientifico,
                "nome_comum": especie.nome_comum,
                "grupo_taxonomico": especie.grupo_taxonomico,
            },
        )

    # Histórico completo de alocações do recinto (atuais + passadas).
    hist_stmt = (
        select(Alocacao, Animal, Especie)
        .join(Animal, Animal.nro_reg == Alocacao.animal)
        .join(Especie, Especie.nome_cientifico == Animal.especie)
        .where(Alocacao.recinto == recinto_gefau)
        .order_by(Alocacao.data_entrada.desc())
    )
    hist = (await db.execute(hist_stmt)).all()
    historico = [
        {
            "nro_reg": animal.nro_reg,
            "apelido": animal.apelido,
            "especie_nome_comum": especie.nome_comum,
            "data_entrada": aloc.data_entrada,
            "data_saida": aloc.data_saida,
            "motivo_saida": aloc.motivo_saida,
        }
        for aloc, animal, especie in hist
    ]

    return {
        **recinto_resumo(recinto),
        "animais_alocados": animais_alocados,
        "especies_presentes": list(especies_presentes.values()),
        "historico_alocacoes": historico,
    }
