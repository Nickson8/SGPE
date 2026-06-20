// Tipos espelhando os schemas Pydantic do backend.

export interface Especie {
  nome_cientifico: string;
  nome_comum: string | null;
  grupo_taxonomico: string | null;
  plano_manejo: string | null;
  quantidade: number | null;
}

export interface Fatia {
  label: string;
  count: number;
}

export interface RecintoCapacidade {
  nome: string;
  gefau: string;
  ocupacao: number;
  capacidade: number;
  percentual: number;
  status: string;
}

export interface UltimaAlocacao {
  nro_reg: number;
  apelido: string | null;
  especie_nome_comum: string | null;
  recinto_nome: string;
  data_entrada: string;
}

export interface Dashboard {
  totais: {
    animais: number;
    especies: number;
    recintos: number;
    recintos_alerta: number;
    especies_com_plano: number;
    pct_com_plano: number;
  };
  grupo_taxonomico: Fatia[];
  sexo: Fatia[];
  plano_manejo: Fatia[];
  recintos_capacidade: RecintoCapacidade[];
  ultimas_alocacoes: UltimaAlocacao[];
}

export interface AnimalResumo {
  nro_reg: number;
  apelido: string | null;
  especie_nome_comum: string | null;
  especie_nome_cientifico: string;
  sexo: string | null;
  nro_gefau: string | null;
  recinto_atual_nome: string | null;
  recinto_atual_gefau: string | null;
}

export interface TriagemPonto {
  data_triagem: string;
  peso_ao_chegar: number | null;
  score_corporal: number | null;
  gravidade_veterinaria: string | null;
  observacoes: string | null;
}

export interface RegistroTimeline {
  tipo: string;
  data_hora: string;
  data_triagem: string;
  ocorrencia: string | null;
  detalhamento: string | null;
  funcionario_nome: string | null;
}

export interface MedicacaoItem {
  medicamento: string;
  dose_pv: number | null;
  data_hora: string;
}

export interface ExameItem {
  tipo_exame: string;
  data_exame: string;
  resultados: string | null;
  observacoes: string | null;
}

export interface AlertaItem {
  data_triagem: string;
  texto: string;
}

export interface AnimalDetalhe {
  nro_reg: number;
  apelido: string | null;
  especie_nome_comum: string | null;
  especie_nome_cientifico: string;
  grupo_taxonomico: string | null;
  sexo: string | null;
  data_nasc: string;
  nro_gefau: string | null;
  nro_livro: number;
  plantel: string;
  recinto_atual_nome: string | null;
  recinto_atual_gefau: string | null;
  triagens: TriagemPonto[];
  timeline: RegistroTimeline[];
  medicacoes: MedicacaoItem[];
  exames: ExameItem[];
  restricoes: AlertaItem[];
  riscos: AlertaItem[];
}

export interface RecintoResumo {
  recinto_gefau: string;
  nome: string;
  capacidade_max: number;
  qnt_animais: number;
  qnt_especies: number;
  percentual_ocupacao: number;
  status_ocupacao: string;
}

export interface AnimalAlocado {
  nro_reg: number;
  apelido: string | null;
  especie_nome_comum: string | null;
  sexo: string | null;
  data_entrada: string;
}

export interface EspeciePresente {
  nome_cientifico: string;
  nome_comum: string | null;
  grupo_taxonomico: string | null;
}

export interface AlocacaoHistorico {
  nro_reg: number;
  apelido: string | null;
  especie_nome_comum: string | null;
  data_entrada: string;
  data_saida: string | null;
  motivo_saida: string | null;
}

export interface RecintoDetalhe extends RecintoResumo {
  animais_alocados: AnimalAlocado[];
  especies_presentes: EspeciePresente[];
  historico_alocacoes: AlocacaoHistorico[];
}

export interface RecintoCreate {
  recinto_gefau: string;
  nome: string;
  capacidade_max: number;
}
