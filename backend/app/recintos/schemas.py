from datetime import date
from typing import Annotated

from pydantic import BaseModel, Field, StringConstraints


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
    """Dados de entrada do cadastro de recinto, com validação amigável.

    Strings são aparadas (strip) e não podem ficar vazias; a capacidade deve ser
    um inteiro positivo. Erros geram resposta 422 com mensagem clara ao usuário.
    """

    recinto_gefau: Annotated[
        str,
        StringConstraints(strip_whitespace=True, min_length=1, max_length=30),
    ] = Field(description="Código GEFAU do recinto (único).")
    nome: Annotated[
        str,
        StringConstraints(strip_whitespace=True, min_length=1, max_length=50),
    ] = Field(description="Nome do recinto.")
    capacidade_max: int = Field(ge=1, description="Capacidade máxima (>= 1).")
