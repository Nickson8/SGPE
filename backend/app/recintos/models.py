from datetime import date

from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Recinto(Base):
    """Espelho somente-leitura da tabela RECINTO."""

    __tablename__ = "recinto"

    recinto_gefau: Mapped[str] = mapped_column("recintogefau", primary_key=True)
    nome: Mapped[str] = mapped_column("nome")
    capacidade_max: Mapped[int] = mapped_column("capacidademax")
    qnt_animais: Mapped[int] = mapped_column("qntanimais")
    qnt_especies: Mapped[int] = mapped_column("qntespecies")


class Alocacao(Base):
    """Espelho somente-leitura da tabela ALOCACAO (histórico animal x recinto)."""

    __tablename__ = "alocacao"

    animal: Mapped[int] = mapped_column("animal", primary_key=True)
    recinto: Mapped[str] = mapped_column("recinto", primary_key=True)
    data_entrada: Mapped[date] = mapped_column("dataentrada", primary_key=True)
    data_saida: Mapped[date | None] = mapped_column("datasaida")
    motivo_saida: Mapped[str | None] = mapped_column("motivosaida")
