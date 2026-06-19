from sqlalchemy import String, cast, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.animais.models import (
    Animal,
    Exame,
    MedicamentoAdministrado,
    RegistroBiologico,
    RegistroClinico,
    Restricao,
    Risco,
    Triagem,
)
from app.especies.models import Especie
from app.recintos.models import Alocacao, Recinto
from app.shared.models import Funcionario


async def _recinto_atual(db: AsyncSession, nro_reg: int) -> Recinto | None:
    stmt = (
        select(Recinto)
        .join(Alocacao, Alocacao.recinto == Recinto.recinto_gefau)
        .where(Alocacao.animal == nro_reg, Alocacao.data_saida.is_(None))
        .limit(1)
    )
    return (await db.execute(stmt)).scalars().first()


async def list_animais(db: AsyncSession, q: str | None = None) -> list[dict]:
    stmt = (
        select(Animal, Especie)
        .join(Especie, Especie.nome_cientifico == Animal.especie)
        .order_by(Animal.apelido)
    )
    if q:
        like = f"%{q}%"
        stmt = stmt.where(
            or_(
                Animal.apelido.ilike(like),
                Animal.nro_gefau.ilike(like),
                Especie.nome_comum.ilike(like),
                Especie.nome_cientifico.ilike(like),
                cast(Animal.nro_reg, String).ilike(like),
            )
        )

    rows = (await db.execute(stmt)).all()

    # Recinto atual de todos de uma vez (uma query) para evitar N+1.
    atual_stmt = (
        select(Alocacao.animal, Recinto)
        .join(Recinto, Recinto.recinto_gefau == Alocacao.recinto)
        .where(Alocacao.data_saida.is_(None))
    )
    atual_map = {
        animal_id: recinto for animal_id, recinto in (await db.execute(atual_stmt)).all()
    }

    resultado = []
    for animal, especie in rows:
        rec = atual_map.get(animal.nro_reg)
        resultado.append(
            {
                "nro_reg": animal.nro_reg,
                "apelido": animal.apelido,
                "especie_nome_comum": especie.nome_comum,
                "especie_nome_cientifico": especie.nome_cientifico,
                "sexo": animal.sexo,
                "nro_gefau": animal.nro_gefau,
                "recinto_atual_nome": rec.nome if rec else None,
                "recinto_atual_gefau": rec.recinto_gefau if rec else None,
            }
        )
    return resultado


async def get_animal_detalhe(db: AsyncSession, nro_reg: int) -> dict | None:
    row = (
        await db.execute(
            select(Animal, Especie)
            .join(Especie, Especie.nome_cientifico == Animal.especie)
            .where(Animal.nro_reg == nro_reg)
        )
    ).first()
    if row is None:
        return None
    animal, especie = row

    recinto = await _recinto_atual(db, nro_reg)

    # Mapa de funcionários (cpf -> nome) para enriquecer a timeline.
    func_map = {
        f.cpf: f.nome for f in (await db.execute(select(Funcionario))).scalars().all()
    }

    # Triagens (evolução de peso/score).
    triagens = (
        await db.execute(
            select(Triagem)
            .where(Triagem.animal == nro_reg)
            .order_by(Triagem.data_triagem)
        )
    ).scalars().all()

    # Timeline: registros clínicos + biológicos.
    clinicos = (
        await db.execute(
            select(RegistroClinico).where(RegistroClinico.animal == nro_reg)
        )
    ).scalars().all()
    biologicos = (
        await db.execute(
            select(RegistroBiologico).where(RegistroBiologico.animal == nro_reg)
        )
    ).scalars().all()

    timeline = []
    for rc in clinicos:
        timeline.append(
            {
                "tipo": "clinico",
                "data_hora": rc.data_hora_registro,
                "data_triagem": rc.data_triagem,
                "ocorrencia": rc.ocorrencia,
                "detalhamento": rc.tratamento,
                "funcionario_nome": func_map.get(rc.funcionario),
            }
        )
    for rb in biologicos:
        timeline.append(
            {
                "tipo": "biologico",
                "data_hora": rb.data_hora_registro,
                "data_triagem": rb.data_triagem,
                "ocorrencia": rb.ocorrencia,
                "detalhamento": rb.detalhamento,
                "funcionario_nome": func_map.get(rb.funcionario),
            }
        )
    timeline.sort(key=lambda t: t["data_hora"], reverse=True)

    # Medicações administradas (via registros clínicos do animal).
    med_rows = (
        await db.execute(
            select(MedicamentoAdministrado, RegistroClinico.data_hora_registro)
            .join(RegistroClinico, RegistroClinico.id == MedicamentoAdministrado.id)
            .where(RegistroClinico.animal == nro_reg)
            .order_by(RegistroClinico.data_hora_registro.desc())
        )
    ).all()
    medicacoes = [
        {
            "medicamento": med.medicamento,
            "dose_pv": med.dose_pv,
            "data_hora": data_hora,
        }
        for med, data_hora in med_rows
    ]

    # Exames (via registros clínicos do animal).
    exame_rows = (
        await db.execute(
            select(Exame)
            .join(RegistroClinico, RegistroClinico.id == Exame.id)
            .where(RegistroClinico.animal == nro_reg)
            .order_by(Exame.data_exame.desc())
        )
    ).scalars().all()
    exames = [
        {
            "tipo_exame": e.tipo_exame,
            "data_exame": e.data_exame,
            "resultados": e.resultados,
            "observacoes": e.observacoes,
        }
        for e in exame_rows
    ]

    restricoes = (
        await db.execute(
            select(Restricao)
            .where(Restricao.animal == nro_reg)
            .order_by(Restricao.data_triagem.desc())
        )
    ).scalars().all()
    riscos = (
        await db.execute(
            select(Risco).where(Risco.animal == nro_reg).order_by(Risco.data_triagem.desc())
        )
    ).scalars().all()

    return {
        "nro_reg": animal.nro_reg,
        "apelido": animal.apelido,
        "especie_nome_comum": especie.nome_comum,
        "especie_nome_cientifico": especie.nome_cientifico,
        "grupo_taxonomico": especie.grupo_taxonomico,
        "sexo": animal.sexo,
        "data_nasc": animal.data_nasc,
        "nro_gefau": animal.nro_gefau,
        "nro_livro": animal.nro_livro,
        "plantel": animal.plantel,
        "recinto_atual_nome": recinto.nome if recinto else None,
        "recinto_atual_gefau": recinto.recinto_gefau if recinto else None,
        "triagens": [
            {
                "data_triagem": t.data_triagem,
                "peso_ao_chegar": t.peso_ao_chegar,
                "score_corporal": t.score_corporal,
                "gravidade_veterinaria": t.gravidade_veterinaria,
                "observacoes": t.observacoes,
            }
            for t in triagens
        ],
        "timeline": timeline,
        "medicacoes": medicacoes,
        "exames": exames,
        "restricoes": [
            {"data_triagem": r.data_triagem, "texto": r.restricao} for r in restricoes
        ],
        "riscos": [{"data_triagem": r.data_triagem, "texto": r.risco} for r in riscos],
    }
