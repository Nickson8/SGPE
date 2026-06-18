-----------------------------------------------------------------------
----------------------------- PARTE JUAN ------------------------------
-----------------------------------------------------------------------

CREATE TABLE ESPECIE(
    NomeCientifico VARCHAR2(30) NOT NULL,
    NomeComum VARCHAR2(30),
    GrupoTaxonomico VARCHAR2(30),
    -- 'S': Existe plano, e 'N': Não existe.
    PlanaDeManejo CHAR(1),
    Quantidade INTEGER,

    CONSTRAINT PK_ESPECIE PRIMARY KEY(NomeCientifico),
    CONSTRAINT CK_ESPECIE_PLANODEMANEJO CHECK(PlanaDeManejo IN ('S', 'N'))
);

CREATE TABLE ANIMAL(
    NroReg INTEGER NOT NULL,
    Especie VARCHAR2(30) NOT NULL,
    DataNasc DATE NOT NULL,
    Marcacao1 VARCHAR2(30),
    Marcacao2 VARCHAR2(30),
    Apelido VARCHAR2(30),
    -- 'M': Macho, 'F': Fêmea e 'I': Indeterminado.
    Sexo CHAR(1),
    -- 'S': Pertence ao plantel, 'N': Não pertence.
    Plantel VARCHAR2(30) NOT NULL,
    NroGEFAU VARCHAR2(30),
    NroLivro INTEGER NOT NULL,

    CONSTRAINT PK_ANIMAL PRIMARY KEY(NroReg),
    CONSTRAINT UK1_ANIMAL_NROGEFAU UNIQUE(NroGEFAU),
    CONSTRAINT UK2_ANIMAL_NROLIVRO UNIQUE(NroLivro),
    CONSTRAINT CK_ANIMAL_SEXO CHECK(Sexo IN ('M', 'F', 'I')),
    CONSTRAINT CK_ANIMAL_PLANTEL CHECK(Plantel IN ('S', 'N')),
    CONSTRAINT FK_ANIMAL_ESPECIE FOREIGN KEY(Especie)
        REFERENCES ESPECIE(NomeCientifico)
        -- Oracle já executa o ON DELETE RESTRICT
        -- Utilizar ON UPDATE CASCADE com Triggers
);

CREATE TABLE TRIAGEM(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    PesoAoChegar FLOAT,
    ScoreCorporal FLOAT,
    GravidadeVeterinaria VARCHAR2(30),
    Observacoes VARCHAR2(50),
    IdadeNaTriagem INTEGER,

    CONSTRAINT PK_TRIAGEM PRIMARY KEY(Animal, DataTriagem),
    CONSTRAINT FK_TRIAGEM_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        -- Utilizar ON UPDATE CASCADE com Triggers
);

CREATE TABLE RESTRICOES(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL, -- Corrigido de INTEGER para DATE para bater com a tabela TRIAGEM
    Restricao VARCHAR2(30) NOT NULL,

    CONSTRAINT PK_RESTRICOES PRIMARY KEY(Animal, DataTriagem, Restricao),
    CONSTRAINT FK_RESTRICOES_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE
        -- Utilizar ON UPDATE CASCADE com Triggers
);

CREATE TABLE RISCO(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    Risco VARCHAR2(30) NOT NULL,

    CONSTRAINT PK_RISCO PRIMARY KEY(Animal, DataTriagem, Risco),
    CONSTRAINT FK_RISCO_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE
        -- Utilizar ON UPDATE CASCADE com Triggers
);

CREATE TABLE FUNCIONARIO(
    -- Armazena-se apenas os numeros
    CPF CHAR(11) NOT NULL,
    Nome VARCHAR2(30),
    Telefone VARCHAR2(20),
    -- Tamanho 20 supondo possivel novas funcoes.
    Funcao VARCHAR2(20) DEFAULT 'VISITANTE',

    CONSTRAINT PK_FUNCIONARIO PRIMARY KEY(CPF),
    -- Nomes alterados de CK_CPF, CK_TELEFONE e CK_FUNCAO para evitar colisão de nomes (ORA-02264)
    CONSTRAINT CK_FUNC_CPF CHECK(LENGTH(CPF) = 11),
    CONSTRAINT CK_FUNC_TELEFONE CHECK(LENGTH(Telefone) >= 8),
    CONSTRAINT CK_FUNC_FUNCAO CHECK
        (Funcao IN ('ADMINISTRADOR', 'VETERINARIO', 'BIOLOGO', 'VISITANTE'))
);

CREATE TABLE REGISTROBIOLOGICO(
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    DataHoraRegistro DATE NOT NULL,
    Ocorrencia VARCHAR2(50),
    Detalhamento VARCHAR2(50),
    AnexoLaudoSaude BLOB,
    Funcionario CHAR(11) NOT NULL,

    CONSTRAINT PK_REGISTROBIOLOGICO PRIMARY KEY(Animal, DataTriagem, DataHoraRegistro),
    CONSTRAINT FK_REGISTROBIOLOGICO_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE, -- Adicionada a vírgula que faltava
        -- Utilizar ON UPDATE CASCADE com Triggers
    CONSTRAINT FK_REGISTROBIOLOGICO_FUNCIONARIO FOREIGN KEY(Funcionario)
        REFERENCES FUNCIONARIO(CPF)
        -- O que fazer ao apagar os dados dos funcionários? (Utilizar ON UPDATE CASCADE com Triggers)
);

CREATE TABLE REGISTROCLINICO(
    ID INTEGER NOT NULL,
    Animal INTEGER NOT NULL,
    DataTriagem DATE NOT NULL,
    DataHoraRegistro DATE NOT NULL,
    Ocorrencia VARCHAR2(50) NOT NULL,
    Tratamento VARCHAR2(50),
    Funcionario CHAR(11) NOT NULL,

    CONSTRAINT PK_REGISTROCLINOCO PRIMARY KEY(ID),
    CONSTRAINT UK_REGISTROCLINICO UNIQUE(Animal, DataTriagem, DataHoraRegistro),
    CONSTRAINT FK_REGISTROCLINICO_TRIAGEM FOREIGN KEY(Animal, DataTriagem)
        REFERENCES TRIAGEM(Animal, DataTriagem)
        ON DELETE CASCADE, -- Adicionada a vírgula que faltava
        -- Utilizar ON UPDATE CASCADE com Triggers
    CONSTRAINT FK_REGISTROCLINICO_FUNCIONARIO FOREIGN KEY(Funcionario)
        REFERENCES FUNCIONARIO(CPF)
        -- O que fazer ao apagar os dados dos funcionários? (Utilizar ON UPDATE CASCADE com Triggers)
);

CREATE TABLE MEDICAMENTOADMINISTRADO(
    ID INTEGER NOT NULL,
    Medicamento VARCHAR2(30) NOT NULL,
    DosePV FLOAT,

    CONSTRAINT PK_MEDICAMENTOADMINISTRADO PRIMARY KEY(ID, Medicamento),
    CONSTRAINT FK_MEDICAMENTOADMINISTRADO_REGISTROCLINICO FOREIGN KEY(ID)
        REFERENCES REGISTROCLINICO(ID)
        ON DELETE CASCADE
        -- Utilizar ON UPDATE CASCADE com Triggers
);

CREATE TABLE EXAMES(
    ID INTEGER NOT NULL,
    DataExame DATE NOT NULL,
    TipoExame VARCHAR2(30),
    Resultados VARCHAR2(100),
    Observacoes VARCHAR2(50),

    CONSTRAINT PK_EXAMES PRIMARY KEY(ID, DataExame, TipoExame), -- Alterado o nome da PK para evitar nome duplicado (reutilizado de MEDICAMENTOADMINISTRADO)
    CONSTRAINT FK_EXAMES_REGCLINICO FOREIGN KEY(ID) -- Alterado o nome da FK para evitar nome duplicado
        REFERENCES REGISTROCLINICO(ID)
        ON DELETE CASCADE
        -- Utilizar ON UPDATE CASCADE com Triggers
);

-----------------------------------------------------------------------
--------------------------- PARTE DANTE -------------------------------
-----------------------------------------------------------------------

CREATE TABLE RECINTO(
    RecintoGEFAU VARCHAR2(30) NOT NULL,
    Nome VARCHAR2(50) NOT NULL,
    CapacidadeMax INTEGER NOT NULL,
    QntAnimais INTEGER DEFAULT 0 NOT NULL,
    QntEspecies INTEGER DEFAULT 0 NOT NULL,

    CONSTRAINT PK_RECINTO PRIMARY KEY(RecintoGEFAU),
    CONSTRAINT CK_RECINTO_CAPACIDADE CHECK (QntAnimais <= CapacidadeMax)
    -- Nota 4: A quantidade de animais no recinto não pode ultrapassar sua capacidade máxima.
);

CREATE TABLE ALOCACAO(
    Animal INTEGER NOT NULL,
    Recinto VARCHAR2(30) NOT NULL,
    DataEntrada DATE NOT NULL,
    DataSaida DATE,
    MotivoSaida VARCHAR2(100),

    CONSTRAINT PK_ALOCACAO PRIMARY KEY(Animal, Recinto, DataEntrada),
    CONSTRAINT FK_ALOCACAO_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE,
        -- ON DELETE CASCADE: Se o registro de um animal for deletado do sistema, o histórico de alocações dele perde o sentido e deve ser removido.
    CONSTRAINT FK_ALOCACAO_RECINTO FOREIGN KEY(Recinto)
        REFERENCES RECINTO(RecintoGEFAU),
        -- Sem ON DELETE CASCADE (Age como RESTRICT): Evita a deleção acidental de um recinto que possua histórico de animais morando nele.
    CONSTRAINT CK_ALOCACAO_DATAS CHECK (DataSaida IS NULL OR DataSaida > DataEntrada)
    -- Nota 5: A data de saída deve ser obrigatoriamente posterior à data de entrada.
);

CREATE TABLE CASAL(
    Animal_1 INTEGER NOT NULL,
    Animal_2 INTEGER NOT NULL,

    CONSTRAINT PK_CASAL PRIMARY KEY(Animal_1, Animal_2),
    CONSTRAINT FK_CASAL_ANIMAL1 FOREIGN KEY(Animal_1)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE,
    CONSTRAINT FK_CASAL_ANIMAL2 FOREIGN KEY(Animal_2)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE,
        -- ON DELETE CASCADE em ambos: Um casal é uma agregação que deixa de existir caso um dos animais seja deletado.
    CONSTRAINT CK_CASAL_DIFERENTES CHECK (Animal_1 <> Animal_2)
    -- Nota 6: Um animal não pode ser pareado consigo mesmo.
);

CREATE TABLE PROLE(
    Pai INTEGER NOT NULL,
    Mae INTEGER NOT NULL,
    Prole INTEGER NOT NULL,

    CONSTRAINT PK_PROLE PRIMARY KEY(Prole),
    CONSTRAINT FK_PROLE_CASAL FOREIGN KEY(Pai, Mae)
        REFERENCES CASAL(Animal_1, Animal_2)
        ON DELETE CASCADE,
        -- ON DELETE CASCADE: Deletar o registro de um casal deleta apenas a "ligação de paternidade" nesta tabela associativa, e não o animal filhote em si.
    CONSTRAINT FK_PROLE_ANIMAL FOREIGN KEY(Prole)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        -- ON DELETE CASCADE: Se o animal filhote for removido do BD, sua ligação de quem são os pais some.
);

CREATE TABLE ITEMCARDAPIO(
    Animal INTEGER NOT NULL,
    Alimento VARCHAR2(50) NOT NULL,
    Quantidade FLOAT,
    Observacoes VARCHAR2(100),
    Frequencia VARCHAR2(30),

    CONSTRAINT PK_ITEMCARDAPIO PRIMARY KEY(Animal, Alimento),
    CONSTRAINT FK_ITEMCARDAPIO_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE
        -- ON DELETE CASCADE: Excluir o animal exclui também sua dieta.
);

CREATE TABLE DESCRICAOROTINA(
    Animal INTEGER NOT NULL,
    TipoRotina VARCHAR2(20) NOT NULL,
    Objetivo VARCHAR2(100) NOT NULL,
    Metodologia VARCHAR2(500) NOT NULL,
    Ferramentas VARCHAR2(200),
    Frequencia VARCHAR2(30) NOT NULL, -- Movido para cá conforme Nota 2.6
    -- Atributo específico de Enriquecimento
    Tipo VARCHAR2(30),
    -- Atributo específico de Condicionamento
    Comandos VARCHAR2(200),

    CONSTRAINT PK_DESCRICAOROTINA PRIMARY KEY(Animal, TipoRotina),
    CONSTRAINT FK_DESCRICAOROTINA_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE,
        -- ON DELETE CASCADE: Excluir animal exclui as rotinas prescritas para ele.
    CONSTRAINT CK_DESCRICAOROTINA_TIPOROT CHECK (TipoRotina IN ('Condicionamento', 'Enriquecimento'))
    -- Nota 10: O atributo TipoRotina é restrito a estes dois valores literais.
);

CREATE TABLE REGISTROROTINA(
    Animal INTEGER NOT NULL,
    TipoRotina VARCHAR2(20) NOT NULL,
    DataHorario DATE NOT NULL,
    Observacoes VARCHAR2(100),
    DiasSemana CHAR(7) NOT NULL,

    CONSTRAINT PK_REGISTROROTINA PRIMARY KEY(Animal, TipoRotina, DataHorario),
    CONSTRAINT FK_REGISTROROTINA_DESC FOREIGN KEY(Animal, TipoRotina)
        REFERENCES DESCRICAOROTINA(Animal, TipoRotina)
        ON DELETE CASCADE,
        -- ON DELETE CASCADE: Excluir a descrição da rotina base invalida o histórico de execuções dela.
    CONSTRAINT CK_REGISTROROTINA_DIAS CHECK (LENGTH(DiasSemana) = 7 AND REGEXP_LIKE(DiasSemana, '^[01]{7}$'))
    -- Nota 26: Formato exato X1X2X3X4X5X6X7, onde Xi=1 ou 0. O Regex garante que apenas sequências binárias de 7 dígitos sejam aceitas.
);


-----------------------
------- ATENÇÃO -------
-----------------------
--  Alterações sobre --
--   Trab 2 podem    --
--  refletir aqui!!! --
-----------------------

CREATE TABLE DOCUMENTO(
    TipoDocumento VARCHAR2(50) NOT NULL,
    NroDocumento VARCHAR2(50) NOT NULL,
    Animal INTEGER NOT NULL,
    Anexo BLOB NOT NULL,
    DataCadastro DATE NOT NULL,
    Observacao VARCHAR2(200),
    TipoMigracao VARCHAR2(20),
    Destino VARCHAR2(50),
    Origem VARCHAR2(50),

    CONSTRAINT PK_DOCUMENTO PRIMARY KEY(TipoDocumento, NroDocumento),
    CONSTRAINT FK_DOCUMENTO_ANIMAL FOREIGN KEY(Animal)
        REFERENCES ANIMAL(NroReg)
        ON DELETE CASCADE,
        -- ON DELETE CASCADE: A menos que restrições legais da BioParque exijam a retention do documento órfão, a exclusão do animal limpa os documentos vinculados.
    CONSTRAINT CK_DOCUMENTO_MIGRACAO CHECK (TipoMigracao IN ('Entrada', 'Baixa', NULL)),
    -- Nota 6/21: Aceita os tipos "Entrada" e "Baixa". Permite NULL para documentos comuns (ex: laudo necrópsia) que não são de migração.
    CONSTRAINT CK_DOCUMENTO_ESPECIALIZACAO CHECK (
        (TipoMigracao = 'Entrada' AND Origem IS NOT NULL AND Destino IS NULL) OR
        (TipoMigracao = 'Baixa' AND Destino IS NOT NULL AND Origem IS NULL) OR
        (TipoMigracao IS NULL AND Origem IS NULL AND Destino IS NULL)
    )
    -- Garante a consistência dos atributos das especializações que foram colapsadas na tabela base (Nota 21).
);