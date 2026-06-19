from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Especie(Base):
    """Espelho somente-leitura da tabela ESPECIE."""

    __tablename__ = "especie"

    nome_cientifico: Mapped[str] = mapped_column("nomecientifico", primary_key=True)
    nome_comum: Mapped[str | None] = mapped_column("nomecomum")
    grupo_taxonomico: Mapped[str | None] = mapped_column("grupotaxonomico")
    # 'S' = existe plano de manejo; 'N' = não existe.
    plano_manejo: Mapped[str | None] = mapped_column("planademanejo")
    quantidade: Mapped[int | None] = mapped_column("quantidade")
