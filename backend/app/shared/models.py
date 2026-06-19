"""Espelhos somente-leitura das tabelas sem módulo/endpoint dedicado nesta versão.

Mapeadas para completude do esquema e para uso futuro (cardápio, rotinas,
genealogia, documentos). Não expostas via API ainda.
"""

from datetime import date, datetime

from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Funcionario(Base):
    __tablename__ = "funcionario"

    cpf: Mapped[str] = mapped_column("cpf", primary_key=True)
    nome: Mapped[str | None] = mapped_column("nome")
    telefone: Mapped[str | None] = mapped_column("telefone")
    funcao: Mapped[str | None] = mapped_column("funcao")


class Casal(Base):
    __tablename__ = "casal"

    animal_1: Mapped[int] = mapped_column("animal_1", primary_key=True)
    animal_2: Mapped[int] = mapped_column("animal_2", primary_key=True)


class Prole(Base):
    __tablename__ = "prole"

    pai: Mapped[int] = mapped_column("pai")
    mae: Mapped[int] = mapped_column("mae")
    prole: Mapped[int] = mapped_column("prole", primary_key=True)


class ItemCardapio(Base):
    __tablename__ = "itemcardapio"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    alimento: Mapped[str] = mapped_column("alimento", primary_key=True)
    quantidade: Mapped[float | None] = mapped_column("quantidade")
    observacoes: Mapped[str | None] = mapped_column("observacoes")
    frequencia: Mapped[str | None] = mapped_column("frequencia")


class DescricaoRotina(Base):
    __tablename__ = "descricaorotina"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    tipo_rotina: Mapped[str] = mapped_column("tiporotina", primary_key=True)
    objetivo: Mapped[str] = mapped_column("objetivo")
    metodologia: Mapped[str] = mapped_column("metodologia")
    ferramentas: Mapped[str | None] = mapped_column("ferramentas")
    frequencia: Mapped[str] = mapped_column("frequencia")
    tipo: Mapped[str | None] = mapped_column("tipo")
    comandos: Mapped[str | None] = mapped_column("comandos")


class RegistroRotina(Base):
    __tablename__ = "registrorotina"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    tipo_rotina: Mapped[str] = mapped_column("tiporotina", primary_key=True)
    data_horario: Mapped[datetime] = mapped_column("datahorario", primary_key=True)
    observacoes: Mapped[str | None] = mapped_column("observacoes")
    dias_semana: Mapped[str] = mapped_column("diassemana")


class Documento(Base):
    __tablename__ = "documento"

    tipo_documento: Mapped[str] = mapped_column("tipodocumento", primary_key=True)
    nro_documento: Mapped[str] = mapped_column("nrodocumento", primary_key=True)
    animal: Mapped[int] = mapped_column("animal")
    data_cadastro: Mapped[date] = mapped_column("datacadastro")
    observacao: Mapped[str | None] = mapped_column("observacao")
    tipo_migracao: Mapped[str | None] = mapped_column("tipomigracao")
    destino: Mapped[str | None] = mapped_column("destino")
    origem: Mapped[str | None] = mapped_column("origem")
