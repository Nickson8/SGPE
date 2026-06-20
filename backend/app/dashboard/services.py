from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.recintos.services import percentual_ocupacao, status_ocupacao

# Todas as operações usam SQL explícito (text()), conforme exigido pelo projeto
# (OBS 3). Os nomes de tabela/coluna seguem init-scripts/01-create-tables.sql.

SEXO_LABELS = {"M": "Macho", "F": "Fêmea", "I": "Indeterminado"}
PLANO_LABELS = {"S": "Com plano de manejo", "N": "Sem plano de manejo"}
ESPECIES_AMEACADAS_NOTA = "Plano de manejo = 'S'"


async def get_dashboard(db: AsyncSession) -> dict:
    total_animais = (
        await db.execute(text("SELECT COUNT(*) FROM animal"))
    ).scalar_one()
    total_especies = (
        await db.execute(text("SELECT COUNT(*) FROM especie"))
    ).scalar_one()

    recintos = (
        await db.execute(
            text(
                "SELECT recinto_gefau, nome, capacidade_max, qnt_animais, "
                "qnt_especies FROM recinto"
            )
        )
    ).mappings().all()
    recintos_alerta = sum(
        1
        for r in recintos
        if percentual_ocupacao(r["qnt_animais"], r["capacidade_max"]) >= 75
    )

    especies_com_plano = (
        await db.execute(
            text("SELECT COUNT(*) FROM especie WHERE plano_de_manejo = 'S'")
        )
    ).scalar_one()
    pct_com_plano = (
        round(especies_com_plano / total_especies * 100, 1) if total_especies else 0.0
    )

    # Distribuição por grupo taxonômico (soma das quantidades das espécies).
    grupo_rows = (
        await db.execute(
            text(
                "SELECT grupo_taxonomico, COALESCE(SUM(quantidade), 0) AS total "
                "FROM especie "
                "GROUP BY grupo_taxonomico "
                "ORDER BY SUM(quantidade) DESC"
            )
        )
    ).mappings().all()
    grupo_taxonomico = [
        {"label": r["grupo_taxonomico"] or "—", "count": int(r["total"])}
        for r in grupo_rows
    ]

    # Distribuição por sexo (contagem de animais).
    sexo_rows = (
        await db.execute(
            text(
                "SELECT sexo, COUNT(*) AS total FROM animal "
                "GROUP BY sexo ORDER BY sexo"
            )
        )
    ).mappings().all()
    sexo = [
        {
            "label": SEXO_LABELS.get((r["sexo"] or "").strip(), r["sexo"] or "—"),
            "count": r["total"],
        }
        for r in sexo_rows
    ]

    # Distribuição por plano de manejo (S/N).
    plano_rows = (
        await db.execute(
            text(
                "SELECT plano_de_manejo, COUNT(*) AS total FROM especie "
                "GROUP BY plano_de_manejo ORDER BY plano_de_manejo"
            )
        )
    ).mappings().all()
    plano_manejo = [
        {
            "label": PLANO_LABELS.get(
                (r["plano_de_manejo"] or "").strip(), r["plano_de_manejo"] or "—"
            ),
            "count": r["total"],
        }
        for r in plano_rows
    ]

    # Capacidade dos recintos (ordenado por ocupação desc).
    recintos_capacidade = sorted(
        [
            {
                "nome": r["nome"],
                "gefau": r["recinto_gefau"],
                "ocupacao": r["qnt_animais"],
                "capacidade": r["capacidade_max"],
                "percentual": percentual_ocupacao(
                    r["qnt_animais"], r["capacidade_max"]
                ),
                "status": status_ocupacao(
                    percentual_ocupacao(r["qnt_animais"], r["capacidade_max"])
                ),
            }
            for r in recintos
        ],
        key=lambda x: -x["percentual"],
    )

    # Últimas alocações (entradas mais recentes).
    ult_rows = (
        await db.execute(
            text(
                "SELECT a.nro_reg, a.apelido, e.nome_comum, r.nome AS recinto_nome, "
                "       al.data_entrada "
                "FROM alocacao al "
                "  JOIN animal a ON a.nro_reg = al.animal "
                "  JOIN especie e ON e.nome_cientifico = a.especie "
                "  JOIN recinto r ON r.recinto_gefau = al.recinto "
                "ORDER BY al.data_entrada DESC "
                "LIMIT 6"
            )
        )
    ).mappings().all()
    ultimas_alocacoes = [
        {
            "nro_reg": r["nro_reg"],
            "apelido": r["apelido"],
            "especie_nome_comum": r["nome_comum"],
            "recinto_nome": r["recinto_nome"],
            "data_entrada": r["data_entrada"],
        }
        for r in ult_rows
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
