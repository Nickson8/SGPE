-- =====================================================================
-- SGPE — Esquema do banco (PostgreSQL)
-- =====================================================================
-- Tradução fiel do DDL original (sql/create-tables.sql), que foi escrito
-- para Oracle, para PostgreSQL. O ESQUEMA é o núcleo do projeto e NÃO é
-- alterado em sua semântica: mesmas tabelas, colunas, chaves e restrições.
--
-- Conversões Oracle -> PostgreSQL aplicadas:
--   VARCHAR2(n)                 -> VARCHAR(n)
--   FLOAT                       -> DOUBLE PRECISION
--   BLOB                        -> BYTEA
--   REGEXP_LIKE(col, '...')     -> col ~ '...'
--   "ON UPDATE CASCADE c/ Trigger" (comentário Oracle) -> ON UPDATE CASCADE nativo
--   Correção do nome da PK PK_REGISTROCLINOCO -> PK_REGISTROCLINICO
--
-- Identificadores não são "aspeados": o PostgreSQL os normaliza para
-- minúsculas (ex.: NomeCientifico == nomecientifico). Os modelos
-- SQLAlchemy do backend mapeiam os nomes em minúsculas.
--
-- Este script roda automaticamente na PRIMEIRA inicialização do container
-- Postgres (/docker-entrypoint-initdb.d), em ordem de nome de arquivo.
-- =====================================================================

-----------------------------------------------------------------------
----------------------------- PARTE JUAN ------------------------------
-----------------------------------------------------------------------

CREATE TABLE ESPECIE(
    NomeCientifico VARCHAR(30) NOT NULL,
    NomeComum VARCHAR(30),
    GrupoTaxonomico VARCHAR(30),
    -- 'S': Existe plano, e 'N': Não existe.
    PlanaDeManejo CHAR(1),
    Quantidade INTEGER,

    CONSTRAINT PK_ESPECIE PRIMARY KEY(NomeCientifico),
    CONSTRAINT CK_ESPECIE_PLANODEMANEJO CHECK(PlanaDeManejo IN ('S', 'N'))
);

CREATE TABLE ANIMAL(
    NroReg INTEGER NOT NULL,
    Especie VARCHAR(30) NOT NULL,
    DataNasc DATE NOT NULL,
    Marcacao1 VARCHAR(30),
    Marcacao2 VARCHAR(30),
    Apelido VARCHAR(30),
    -- 'M': Macho, 'F': Fêmea e 'I': Indeterminado.
    Sexo CHAR(1),
    -- 'S': Pertence ao plantel, 'N': Não pertence.
    Plantel VARCHAR(30) NOT NULL,
    NroGEFAU VARCHAR(30),
    NroLivro INTEGER NOT NULL,

    CONSTRAINT PK_ANIMAL PRIMARY KEY(NroReg),
    CONSTRAINT UK1_ANIMAL_NROGEFAU UNIQUE(NroGEFAU),
    CONSTRAINT UK2_ANIMAL_NROLIVRO UNIQUE(NroLivro),
    CONSTRAINT CK_ANIMAL_SEXO CHECK(Sexo IN ('M', 'F', 'I')),
    CONSTRAINT CK_ANIMAL_PLANTEL CHECK(Plantel IN ('S', 'N')),
    CONSTRAINT FK_ANIMAL_ESPECIE FOREIGN KEY(Especie)
        REFERENCES ESPECIE(NomeCientifico)
        ON UPDATE CASCADE
);

CREATE TABLE TRIAGEM(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    PesoAoChegar DOUBLE PRECISION,
    ScoreCorporal DOUBLE PRECISION,
    GravidadeVeterinaria VARCHAR(30),
    Observacoes VARCHAR(50),
    IdadeNaTriagem INTEGER,

    CONSTRAINT PK_TRIAGEM PRIMARY KEY(Animal, DataTriagem),
    CONSTRAINT FK_TRIAGEM_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE RESTRICOES(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    Restricao VARCHAR(30) NOT NULL,

    CONSTRAINT PK_RESTRICOES PRIMARY KEY(Animal, DataTriagem, Restricao),
    CONSTRAINT FK_RESTRICOES_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE RISCO(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    Risco VARCHAR(30) NOT NULL,

    CONSTRAINT PK_RISCO PRIMARY KEY(Animal, DataTriagem, Risco),
    CONSTRAINT FK_RISCO_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE FUNCIONARIO(
    -- Armazena-se apenas os numeros
    CPF CHAR(11) NOT NULL,
    Nome VARCHAR(30),
    Telefone VARCHAR(20),
    -- Tamanho 20 supondo possivel novas funcoes.
    Funcao VARCHAR(20) DEFAULT 'VISITANTE',

    CONSTRAINT PK_FUNCIONARIO PRIMARY KEY(CPF),
    CONSTRAINT CK_FUNC_CPF CHECK(LENGTH(CPF) = 11),
    CONSTRAINT CK_FUNC_TELEFONE CHECK(LENGTH(Telefone) >= 8),
    CONSTRAINT CK_FUNC_FUNCAO CHECK
        (Funcao IN ('ADMINISTRADOR', 'VETERINARIO', 'BIOLOGO', 'VISITANTE'))
);

CREATE TABLE REGISTROBIOLOGICO(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    DataHoraRegistro TIMESTAMP NOT NULL,
    Ocorrencia VARCHAR(50),
    Detalhamento VARCHAR(50),
    AnexoLaudoSaude BYTEA,
    Funcionario CHAR(11) NOT NULL,

    CONSTRAINT PK_REGISTROBIOLOGICO PRIMARY KEY(Animal, DataTriagem, DataHoraRegistro),
    CONSTRAINT FK_REGISTROBIOLOGICO_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_REGISTROBIOLOGICO_FUNCIONARIO FOREIGN KEY(Funcionario)
        REFERENCES FUNCIONARIO(CPF)
        ON UPDATE CASCADE
);

CREATE TABLE REGISTROCLINICO(
    ID INTEGER NOT NULL,
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    DataHoraRegistro TIMESTAMP NOT NULL,
    Ocorrencia VARCHAR(50) NOT NULL,
    Tratamento VARCHAR(50),
    Funcionario CHAR(11) NOT NULL,

    CONSTRAINT PK_REGISTROCLINICO PRIMARY KEY(ID),
    CONSTRAINT UK_REGISTROCLINICO UNIQUE(Animal, DataTriagem, DataHoraRegistro),
    CONSTRAINT FK_REGISTROCLINICO_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_REGISTROCLINICO_FUNCIONARIO FOREIGN KEY(Funcionario)
        REFERENCES FUNCIONARIO(CPF)
        ON UPDATE CASCADE
);

CREATE TABLE MEDICAMENTOADMINISTRADO(
    ID INTEGER NOT NULL,
    Medicamento VARCHAR(30) NOT NULL,
    DosePV DOUBLE PRECISION,

    CONSTRAINT PK_MEDICAMENTOADMINISTRADO PRIMARY KEY(ID, Medicamento),
    CONSTRAINT FK_MEDICAMENTOADMINISTRADO_REGISTROCLINICO FOREIGN KEY(ID)
        REFERENCES REGISTROCLINICO(ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE EXAMES(
    ID INTEGER NOT NULL,
    DataExame DATE NOT NULL,
    TipoExame VARCHAR(30),
    Resultados VARCHAR(100),
    Observacoes VARCHAR(50),

    CONSTRAINT PK_EXAMES PRIMARY KEY(ID, DataExame, TipoExame),
    CONSTRAINT FK_EXAMES_REGCLINICO FOREIGN KEY(ID)
        REFERENCES REGISTROCLINICO(ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-----------------------------------------------------------------------
--------------------------- PARTE DANTE -------------------------------
-----------------------------------------------------------------------

CREATE TABLE RECINTO(
    RecintoGEFAU VARCHAR(30) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    CapacidadeMax INTEGER NOT NULL,
    QntAnimais INTEGER DEFAULT 0 NOT NULL,
    QntEspecies INTEGER DEFAULT 0 NOT NULL,

    CONSTRAINT PK_RECINTO PRIMARY KEY(RecintoGEFAU),
    -- Nota 4: A quantidade de animais no recinto não pode ultrapassar sua capacidade máxima.
    CONSTRAINT CK_RECINTO_CAPACIDADE CHECK (QntAnimais <= CapacidadeMax)
);

CREATE TABLE ALOCACAO(
    Animal INTEGER NOT NULL,
    Recinto VARCHAR(30) NOT NULL,
    DataEntrada DATE NOT NULL,
    DataSaida DATE,
    MotivoSaida VARCHAR(100),

    CONSTRAINT PK_ALOCACAO PRIMARY KEY(Animal, Recinto, DataEntrada),
    -- ON DELETE CASCADE: deletar o animal remove seu histórico de alocações.
    CONSTRAINT FK_ALOCACAO_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Sem ON DELETE CASCADE (RESTRICT): evita deletar recinto com histórico.
    CONSTRAINT FK_ALOCACAO_RECINTO FOREIGN KEY(Recinto)
        REFERENCES RECINTO(RecintoGEFAU)
        ON UPDATE CASCADE,
    -- Nota 5: A data de saída deve ser posterior à de entrada.
    CONSTRAINT CK_ALOCACAO_DATAS CHECK (DataSaida IS NULL OR DataSaida > DataEntrada)
);

CREATE TABLE CASAL(
    Animal_1 INTEGER NOT NULL,
    Animal_2 INTEGER NOT NULL,

    CONSTRAINT PK_CASAL PRIMARY KEY(Animal_1, Animal_2),
    CONSTRAINT FK_CASAL_ANIMAL1 FOREIGN KEY(Animal_1)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_CASAL_ANIMAL2 FOREIGN KEY(Animal_2)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Nota 6: Um animal não pode ser pareado consigo mesmo.
    CONSTRAINT CK_CASAL_DIFERENTES CHECK (Animal_1 <> Animal_2)
);

CREATE TABLE PROLE(
    Pai INTEGER NOT NULL,
    Mae INTEGER NOT NULL,
    Prole INTEGER NOT NULL,

    CONSTRAINT PK_PROLE PRIMARY KEY(Prole),
    CONSTRAINT FK_PROLE_CASAL FOREIGN KEY(Pai, Mae)
        REFERENCES CASAL(Animal_1, Animal_2)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_PROLE_ANIMAL FOREIGN KEY(Prole)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ITEMCARDAPIO(
    Animal INTEGER NOT NULL,
    Alimento VARCHAR(50) NOT NULL,
    Quantidade DOUBLE PRECISION,
    Observacoes VARCHAR(100),
    Frequencia VARCHAR(30),

    CONSTRAINT PK_ITEMCARDAPIO PRIMARY KEY(Animal, Alimento),
    CONSTRAINT FK_ITEMCARDAPIO_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE DESCRICAOROTINA(
    Animal INTEGER NOT NULL,
    TipoRotina VARCHAR(20) NOT NULL,
    Objetivo VARCHAR(100) NOT NULL,
    Metodologia VARCHAR(500) NOT NULL,
    Ferramentas VARCHAR(200),
    Frequencia VARCHAR(30) NOT NULL,
    -- Atributo específico de Enriquecimento
    Tipo VARCHAR(30),
    -- Atributo específico de Condicionamento
    Comandos VARCHAR(200),

    CONSTRAINT PK_DESCRICAOROTINA PRIMARY KEY(Animal, TipoRotina),
    CONSTRAINT FK_DESCRICAOROTINA_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Nota 10: TipoRotina restrito a estes dois valores literais.
    CONSTRAINT CK_DESCRICAOROTINA_TIPOROT CHECK (TipoRotina IN ('Condicionamento', 'Enriquecimento'))
);

CREATE TABLE REGISTROROTINA(
    Animal INTEGER NOT NULL,
    TipoRotina VARCHAR(20) NOT NULL,
    DataHorario TIMESTAMP NOT NULL,
    Observacoes VARCHAR(100),
    DiasSemana CHAR(7) NOT NULL,

    CONSTRAINT PK_REGISTROROTINA PRIMARY KEY(Animal, TipoRotina, DataHorario),
    CONSTRAINT FK_REGISTROROTINA_DESC FOREIGN KEY(Animal, TipoRotina)
        REFERENCES DESCRICAOROTINA(Animal, TipoRotina)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Nota 26: Formato exato X1..X7, onde Xi=1 ou 0 (sequência binária de 7 dígitos).
    CONSTRAINT CK_REGISTROROTINA_DIAS CHECK (LENGTH(DiasSemana) = 7 AND DiasSemana ~ '^[01]{7}$')
);

CREATE TABLE DOCUMENTO(
    TipoDocumento VARCHAR(50) NOT NULL,
    NroDocumento VARCHAR(50) NOT NULL,
    Animal INTEGER NOT NULL,
    Anexo BYTEA NOT NULL,
    DataCadastro DATE NOT NULL,
    Observacao VARCHAR(200),
    TipoMigracao VARCHAR(20),
    Destino VARCHAR(50),
    Origem VARCHAR(50),

    CONSTRAINT PK_DOCUMENTO PRIMARY KEY(TipoDocumento, NroDocumento),
    CONSTRAINT FK_DOCUMENTO_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Nota 6/21: aceita "Entrada"/"Baixa"; NULL para documentos comuns (não-migração).
    CONSTRAINT CK_DOCUMENTO_MIGRACAO CHECK (TipoMigracao IN ('Entrada', 'Baixa', NULL)),
    -- Consistência dos atributos das especializações colapsadas na base (Nota 21).
    CONSTRAINT CK_DOCUMENTO_ESPECIALIZACAO CHECK (
        (TipoMigracao = 'Entrada' AND Origem IS NOT NULL AND Destino IS NULL) OR
        (TipoMigracao = 'Baixa' AND Destino IS NOT NULL AND Origem IS NULL) OR
        (TipoMigracao IS NULL AND Origem IS NULL AND Destino IS NULL)
    )
);
