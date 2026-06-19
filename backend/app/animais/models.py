from datetime import date, datetime

from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Animal(Base):
    """Espelho somente-leitura da tabela ANIMAL."""

    __tablename__ = "animal"

    nro_reg: Mapped[int] = mapped_column("nroreg", primary_key=True)
    especie: Mapped[str] = mapped_column("especie")
    data_nasc: Mapped[date] = mapped_column("datanasc")
    marcacao_1: Mapped[str | None] = mapped_column("marcacao1")
    marcacao_2: Mapped[str | None] = mapped_column("marcacao2")
    apelido: Mapped[str | None] = mapped_column("apelido")
    # 'M' | 'F' | 'I'
    sexo: Mapped[str | None] = mapped_column("sexo")
    plantel: Mapped[str] = mapped_column("plantel")
    nro_gefau: Mapped[str | None] = mapped_column("nrogefau")
    nro_livro: Mapped[int] = mapped_column("nrolivro")


class Triagem(Base):
    """Espelho somente-leitura da tabela TRIAGEM (peso/score por data)."""

    __tablename__ = "triagem"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    data_triagem: Mapped[date] = mapped_column("datatriagem", primary_key=True)
    peso_ao_chegar: Mapped[float | None] = mapped_column("pesoaochegar")
    score_corporal: Mapped[float | None] = mapped_column("scorecorporal")
    gravidade_veterinaria: Mapped[str | None] = mapped_column("gravidadeveterinaria")
    observacoes: Mapped[str | None] = mapped_column("observacoes")
    idade_na_triagem: Mapped[int | None] = mapped_column("idadenatriagem")


class RegistroClinico(Base):
    """Espelho somente-leitura da tabela REGISTROCLINICO."""

    __tablename__ = "registroclinico"

    id: Mapped[int] = mapped_column("id", primary_key=True)
    animal: Mapped[int] = mapped_column("animal")
    data_triagem: Mapped[date] = mapped_column("datatriagem")
    data_hora_registro: Mapped[datetime] = mapped_column("datahoraregistro")
    ocorrencia: Mapped[str] = mapped_column("ocorrencia")
    tratamento: Mapped[str | None] = mapped_column("tratamento")
    funcionario: Mapped[str] = mapped_column("funcionario")


class RegistroBiologico(Base):
    """Espelho somente-leitura da tabela REGISTROBIOLOGICO."""

    __tablename__ = "registrobiologico"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    data_triagem: Mapped[date] = mapped_column("datatriagem", primary_key=True)
    data_hora_registro: Mapped[datetime] = mapped_column("datahoraregistro", primary_key=True)
    ocorrencia: Mapped[str | None] = mapped_column("ocorrencia")
    detalhamento: Mapped[str | None] = mapped_column("detalhamento")
    funcionario: Mapped[str] = mapped_column("funcionario")


class MedicamentoAdministrado(Base):
    """Espelho somente-leitura da tabela MEDICAMENTOADMINISTRADO."""

    __tablename__ = "medicamentoadministrado"

    id: Mapped[int] = mapped_column("id", primary_key=True)
    medicamento: Mapped[str] = mapped_column("medicamento", primary_key=True)
    dose_pv: Mapped[float | None] = mapped_column("dosepv")


class Exame(Base):
    """Espelho somente-leitura da tabela EXAMES."""

    __tablename__ = "exames"

    id: Mapped[int] = mapped_column("id", primary_key=True)
    data_exame: Mapped[date] = mapped_column("dataexame", primary_key=True)
    tipo_exame: Mapped[str] = mapped_column("tipoexame", primary_key=True)
    resultados: Mapped[str | None] = mapped_column("resultados")
    observacoes: Mapped[str | None] = mapped_column("observacoes")


class Restricao(Base):
    """Espelho somente-leitura da tabela RESTRICOES."""

    __tablename__ = "restricoes"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    data_triagem: Mapped[date] = mapped_column("datatriagem", primary_key=True)
    restricao: Mapped[str] = mapped_column("restricao", primary_key=True)


class Risco(Base):
    """Espelho somente-leitura da tabela RISCO."""

    __tablename__ = "risco"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    data_triagem: Mapped[date] = mapped_column("datatriagem", primary_key=True)
    risco: Mapped[str] = mapped_column("risco", primary_key=True)
