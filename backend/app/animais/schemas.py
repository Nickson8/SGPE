from datetime import date, datetime

from pydantic import BaseModel


class AnimalResumo(BaseModel):
    """Item da lista/busca de animais (tela de seleção do prontuário)."""

    nro_reg: int
    apelido: str | None
    especie_nome_comum: str | None
    especie_nome_cientifico: str
    sexo: str | None
    nro_gefau: str | None
    recinto_atual_nome: str | None
    recinto_atual_gefau: str | None


class TriagemPonto(BaseModel):
    data_triagem: date
    peso_ao_chegar: float | None
    score_corporal: float | None
    gravidade_veterinaria: str | None
    observacoes: str | None


class RegistroTimeline(BaseModel):
    tipo: str  # 'clinico' | 'biologico'
    data_hora: datetime
    data_triagem: date
    ocorrencia: str | None
    detalhamento: str | None  # detalhamento (biológico) ou tratamento (clínico)
    funcionario_nome: str | None


class MedicacaoItem(BaseModel):
    medicamento: str
    dose_pv: float | None
    data_hora: datetime


class ExameItem(BaseModel):
    tipo_exame: str
    data_exame: date
    resultados: str | None
    observacoes: str | None


class AlertaItem(BaseModel):
    data_triagem: date
    texto: str


class AnimalDetalhe(BaseModel):
    nro_reg: int
    apelido: str | None
    especie_nome_comum: str | None
    especie_nome_cientifico: str
    grupo_taxonomico: str | None
    sexo: str | None
    data_nasc: date
    nro_gefau: str | None
    nro_livro: int
    plantel: str
    recinto_atual_nome: str | None
    recinto_atual_gefau: str | None
    triagens: list[TriagemPonto]
    timeline: list[RegistroTimeline]
    medicacoes: list[MedicacaoItem]
    exames: list[ExameItem]
    restricoes: list[AlertaItem]
    riscos: list[AlertaItem]
