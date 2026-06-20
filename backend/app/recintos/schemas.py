from datetime import date

from pydantic import BaseModel


class RecintoResumo(BaseModel):
    """Recinto + indicadores de ocupação (lista e cartões)."""

    recinto_gefau: str
    nome: str
    capacidade_max: int
    qnt_animais: int
    qnt_especies: int
    percentual_ocupacao: float
    status_ocupacao: str  # 'normal' | 'alerta' | 'critico'


class AnimalAlocado(BaseModel):
    nro_reg: int
    apelido: str | None
    especie_nome_comum: str | None
    sexo: str | None
    data_entrada: date


class EspeciePresente(BaseModel):
    nome_cientifico: str
    nome_comum: str | None
    grupo_taxonomico: str | None


class AlocacaoHistorico(BaseModel):
    nro_reg: int
    apelido: str | None
    especie_nome_comum: str | None
    data_entrada: date
    data_saida: date | None
    motivo_saida: str | None


class RecintoDetalhe(RecintoResumo):
    animais_alocados: list[AnimalAlocado]
    especies_presentes: list[EspeciePresente]
    historico_alocacoes: list[AlocacaoHistorico]


class RecintoCreate(BaseModel):
    recinto_gefau: str
    nome: str
    capacidade_max: int
