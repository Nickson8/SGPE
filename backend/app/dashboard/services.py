from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.animais.models import Animal
from app.especies.models import Especie
from app.recintos.models import Alocacao, Recinto
from app.recintos.services import percentual_ocupacao, status_ocupacao

SEXO_LABELS = {"M": "Macho", "F": "Fêmea", "I": "Indeterminado"}
PLANO_LABELS = {"S": "Com plano de manejo", "N": "Sem plano de manejo"}
ESPECIES_AMEACADAS_NOTA = "Plano de manejo = 'S'"


async def get_dashboard(db: AsyncSession) -> dict:
    total_animais = (await db.execute(select(func.count()).select_from(Animal))).scalar_one()
    total_especies = (await db.execute(select(func.count()).select_from(Especie))).scalar_one()

    recintos = (await db.execute(select(Recinto))).scalars().all()
    recintos_alerta = sum(
        1
        for r in recintos
        if percentual_ocupacao(r.qnt_animais, r.capacidade_max) >= 75
    )

    especies_com_plano = (
        await db.execute(
            select(func.count()).select_from(Especie).where(Especie.plano_manejo == "S")
        )
    ).scalar_one()
    pct_com_plano = (
        round(especies_com_plano / total_especies * 100, 1) if total_especies else 0.0
    )

    # Distribuição por grupo taxonômico (soma das quantidades das espécies).
    grupo_rows = (
        await db.execute(
            select(Especie.grupo_taxonomico, func.coalesce(func.sum(Especie.quantidade), 0))
            .group_by(Especie.grupo_taxonomico)
            .order_by(func.sum(Especie.quantidade).desc())
        )
    ).all()
    grupo_taxonomico = [
        {"label": grupo or "—", "count": int(total)} for grupo, total in grupo_rows
    ]

    # Distribuição por sexo (contagem de animais).
    sexo_rows = (
        await db.execute(
            select(Animal.sexo, func.count()).group_by(Animal.sexo).order_by(Animal.sexo)
        )
    ).all()
    sexo = [
        {"label": SEXO_LABELS.get((s or "").strip(), s or "—"), "count": c}
        for s, c in sexo_rows
    ]

    # Distribuição por plano de manejo (S/N).
    plano_rows = (
        await db.execute(
            select(Especie.plano_manejo, func.count())
            .group_by(Especie.plano_manejo)
            .order_by(Especie.plano_manejo)
        )
    ).all()
    plano_manejo = [
        {"label": PLANO_LABELS.get((p or "").strip(), p or "—"), "count": c}
        for p, c in plano_rows
    ]

    # Capacidade dos recintos (ordenado por ocupação desc).
    recintos_capacidade = sorted(
        [
            {
                "nome": r.nome,
                "gefau": r.recinto_gefau,
                "ocupacao": r.qnt_animais,
                "capacidade": r.capacidade_max,
                "percentual": percentual_ocupacao(r.qnt_animais, r.capacidade_max),
                "status": status_ocupacao(
                    percentual_ocupacao(r.qnt_animais, r.capacidade_max)
                ),
            }
            for r in recintos
        ],
        key=lambda x: -x["percentual"],
    )

    # Últimas alocações (entradas mais recentes).
    ult_rows = (
        await db.execute(
            select(Alocacao, Animal, Especie, Recinto)
            .join(Animal, Animal.nro_reg == Alocacao.animal)
            .join(Especie, Especie.nome_cientifico == Animal.especie)
            .join(Recinto, Recinto.recinto_gefau == Alocacao.recinto)
            .order_by(Alocacao.data_entrada.desc())
            .limit(6)
        )
    ).all()
    ultimas_alocacoes = [
        {
            "nro_reg": animal.nro_reg,
            "apelido": animal.apelido,
            "especie_nome_comum": especie.nome_comum,
            "recinto_nome": recinto.nome,
            "data_entrada": aloc.data_entrada,
        }
        for aloc, animal, especie, recinto in ult_rows
    ]

    return {
        "totais": {
            "animais": total_animais,
            "especies": total_especies,
            "recintos": len(recintos),
            "recintos_alerta": recintos_alerta,
            "especies_com_plano": especies_com_plano,
            "pct_com_plano": pct_com_plano,
        },
        "grupo_taxonomico": grupo_taxonomico,
        "sexo": sexo,
        "plano_manejo": plano_manejo,
        "recintos_capacidade": recintos_capacidade,
        "ultimas_alocacoes": ultimas_alocacoes,
    }
