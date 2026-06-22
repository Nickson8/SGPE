from pydantic import BaseModel


class EspecieResponse(BaseModel):
    nome_cientifico: str
    nome_comum: str | None
    grupo_taxonomico: str | None
    plano_manejo: str | None
    quantidade: int | None

    model_config = {"from_attributes": True}
