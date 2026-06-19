from datetime import date

from pydantic import BaseModel


class Totais(BaseModel):
    animais: int
    especies: int
    recintos: int
    recintos_alerta: int
    especies_com_plano: int
    pct_com_plano: float


class Fatia(BaseModel):
    label: str
    count: int


class RecintoCapacidade(BaseModel):
    nome: str
    gefau: str
    ocupacao: int
    capacidade: int
    percentual: float
    status: str


class UltimaAlocacao(BaseModel):
    nro_reg: int
    apelido: str | None
    especie_nome_comum: str | None
    recinto_nome: str
    data_entrada: date


class DashboardResponse(BaseModel):
    totais: Totais
    grupo_taxonomico: list[Fatia]
    sexo: list[Fatia]
    plano_manejo: list[Fatia]
    recintos_capacidade: list[RecintoCapacidade]
    ultimas_alocacoes: list[UltimaAlocacao]
