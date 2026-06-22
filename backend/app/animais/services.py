from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

# Todas as operações usam SQL explícito (text()), conforme exigido pelo projeto
# (OBS 3). Os nomes de tabela/coluna seguem init-scripts/01-create-tables.sql.


async def _recinto_atual(db: AsyncSession, nro_reg: int) -> dict | None:
    sql = text(
        "SELECT r.recinto_gefau, r.nome "
        "FROM alocacao al "
        "  JOIN recinto r ON r.recinto_gefau = al.recinto "
        "WHERE al.animal = :nro_reg AND al.data_saida IS NULL "
        "LIMIT 1"
    )
    row = (await db.execute(sql, {"nro_reg": nro_reg})).mappings().first()
    return dict(row) if row else None


async def list_animais(db: AsyncSession, q: str | None = None) -> list[dict]:
    sql = (
        "SELECT a.nro_reg, a.apelido, a.sexo, a.nro_gefau, "
        "       e.nome_comum, e.nome_cientifico "
        "FROM animal a "
        "  JOIN especie e ON e.nome_cientifico = a.especie"
    )
    params: dict = {}
    if q:
        sql += (
            " WHERE a.apelido ILIKE :busca "
            "    OR a.nro_gefau ILIKE :busca "
            "    OR e.nome_comum ILIKE :busca "
            "    OR e.nome_cientifico ILIKE :busca "
            "    OR CAST(a.nro_reg AS TEXT) ILIKE :busca"
        )
        params["busca"] = f"%{q}%"
    sql += " ORDER BY a.apelido"

    rows = (await db.execute(text(sql), params)).mappings().all()

    # Recinto atual de todos de uma vez (uma query) para evitar N+1.
    atual_rows = (
        await db.execute(
            text(
                "SELECT al.animal, r.recinto_gefau, r.nome "
                "FROM alocacao al "
                "  JOIN recinto r ON r.recinto_gefau = al.recinto "
                "WHERE al.data_saida IS NULL"
            )
        )
    ).mappings().all()
    atual_map = {
        r["animal"]: {"nome": r["nome"], "recinto_gefau": r["recinto_gefau"]}
        for r in atual_rows
    }

    resultado = []
    for a in rows:
        rec = atual_map.get(a["nro_reg"])
        resultado.append(
            {
                "nro_reg": a["nro_reg"],
                "apelido": a["apelido"],
                "especie_nome_comum": a["nome_comum"],
                "especie_nome_cientifico": a["nome_cientifico"],
                "sexo": a["sexo"],
                "nro_gefau": a["nro_gefau"],
                "recinto_atual_nome": rec["nome"] if rec else None,
                "recinto_atual_gefau": rec["recinto_gefau"] if rec else None,
            }
        )
    return resultado


async def get_animal_detalhe(db: AsyncSession, nro_reg: int) -> dict | None:
    animal = (
        await db.execute(
            text(
                "SELECT a.nro_reg, a.apelido, a.sexo, a.data_nasc, a.nro_gefau, "
                "       a.nro_livro, a.plantel, "
                "       e.nome_comum, e.nome_cientifico, e.grupo_taxonomico "
                "FROM animal a "
                "  JOIN especie e ON e.nome_cientifico = a.especie "
                "WHERE a.nro_reg = :nro_reg"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().first()
    if animal is None:
        return None

    recinto = await _recinto_atual(db, nro_reg)

    # Mapa de funcionários (cpf -> nome) para enriquecer a timeline.
    func_rows = (
        await db.execute(text("SELECT cpf, nome FROM funcionario"))
    ).mappings().all()
    func_map = {f["cpf"]: f["nome"] for f in func_rows}

    # Triagens (evolução de peso/score).
    triagens = (
        await db.execute(
            text(
                "SELECT data_triagem, peso_ao_chegar, score_corporal, "
                "       gravidade_veterinaria, observacoes "
                "FROM triagem WHERE animal = :nro_reg ORDER BY data_triagem"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()

    # Timeline: registros clínicos + biológicos.
    clinicos = (
        await db.execute(
            text(
                "SELECT data_hora_registro, data_triagem, ocorrencia, "
                "       tratamento, funcionario "
                "FROM registro_clinico WHERE animal = :nro_reg"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()
    biologicos = (
        await db.execute(
            text(
                "SELECT data_hora_registro, data_triagem, ocorrencia, "
                "       detalhamento, funcionario "
                "FROM registro_biologico WHERE animal = :nro_reg"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()

    timeline = []
    for rc in clinicos:
        timeline.append(
            {
                "tipo": "clinico",
                "data_hora": rc["data_hora_registro"],
                "data_triagem": rc["data_triagem"],
                "ocorrencia": rc["ocorrencia"],
                "detalhamento": rc["tratamento"],
                "funcionario_nome": func_map.get(rc["funcionario"]),
            }
        )
    for rb in biologicos:
        timeline.append(
            {
                "tipo": "biologico",
                "data_hora": rb["data_hora_registro"],
                "data_triagem": rb["data_triagem"],
                "ocorrencia": rb["ocorrencia"],
                "detalhamento": rb["detalhamento"],
                "funcionario_nome": func_map.get(rb["funcionario"]),
            }
        )
    timeline.sort(key=lambda t: t["data_hora"], reverse=True)

    # Medicações administradas (via registros clínicos do animal).
    med_rows = (
        await db.execute(
            text(
                "SELECT m.medicamento, m.dose_pv, rc.data_hora_registro "
                "FROM medicamento_administrado m "
                "  JOIN registro_clinico rc ON rc.id = m.id "
                "WHERE rc.animal = :nro_reg "
                "ORDER BY rc.data_hora_registro DESC"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()
    medicacoes = [
        {
            "medicamento": m["medicamento"],
            "dose_pv": m["dose_pv"],
            "data_hora": m["data_hora_registro"],
        }
        for m in med_rows
    ]

    # Exames (via registros clínicos do animal).
    exame_rows = (
        await db.execute(
            text(
                "SELECT ex.tipo_exame, ex.data_exame, ex.resultados, ex.observacoes "
                "FROM exames ex "
                "  JOIN registro_clinico rc ON rc.id = ex.id "
                "WHERE rc.animal = :nro_reg "
                "ORDER BY ex.data_exame DESC"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()
    exames = [
        {
            "tipo_exame": e["tipo_exame"],
            "data_exame": e["data_exame"],
            "resultados": e["resultados"],
            "observacoes": e["observacoes"],
        }
        for e in exame_rows
    ]

    restricoes = (
        await db.execute(
            text(
                "SELECT data_triagem, restricao FROM restricoes "
                "WHERE animal = :nro_reg ORDER BY data_triagem DESC"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()
    riscos = (
        await db.execute(
            text(
                "SELECT data_triagem, risco FROM risco "
                "WHERE animal = :nro_reg ORDER BY data_triagem DESC"
            ),
            {"nro_reg": nro_reg},
        )
    ).mappings().all()

    return {
        "nro_reg": animal["nro_reg"],
        "apelido": animal["apelido"],
        "especie_nome_comum": animal["nome_comum"],
        "especie_nome_cientifico": animal["nome_cientifico"],
        "grupo_taxonomico": animal["grupo_taxonomico"],
        "sexo": animal["sexo"],
        "data_nasc": animal["data_nasc"],
        "nro_gefau": animal["nro_gefau"],
        "nro_livro": animal["nro_livro"],
        "plantel": animal["plantel"],
        "recinto_atual_nome": recinto["nome"] if recinto else None,
        "recinto_atual_gefau": recinto["recinto_gefau"] if recinto else None,
        "triagens": [
            {
                "data_triagem": t["data_triagem"],
                "peso_ao_chegar": t["peso_ao_chegar"],
                "score_corporal": t["score_corporal"],
                "gravidade_veterinaria": t["gravidade_veterinaria"],
                "observacoes": t["observacoes"],
            }
            for t in triagens
        ],
        "timeline": timeline,
        "medicacoes": medicacoes,
        "exames": exames,
        "restricoes": [
            {"data_triagem": r["data_triagem"], "texto": r["restricao"]}
            for r in restricoes
        ],
        "riscos": [
            {"data_triagem": r["data_triagem"], "texto": r["risco"]} for r in riscos
        ],
    }
