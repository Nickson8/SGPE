-----------------------------------------------------------------------
-------------------------- PARTE JUAN (REVISADA) ----------------------
-----------------------------------------------------------------------

CREATE TABLE especie (
    nome_cientifico VARCHAR(30) NOT NULL,
    nome_comum VARCHAR(30),
    grupo_taxonomico VARCHAR(30),
    -- 'S': Existe plano, e 'N': Não existe.
    plano_de_manejo CHAR(1),
    quantidade INTEGER,

    CONSTRAINT pk_especie PRIMARY KEY(nome_cientifico),
    CONSTRAINT ck_especie_plano_manejo CHECK(plano_de_manejo IN ('S', 'N'))
);

CREATE TABLE animal (
    nro_reg INTEGER NOT NULL,
    especie VARCHAR(30) NOT NULL,
    data_nasc DATE NOT NULL,
    marcacao_1 VARCHAR(30),
    marcacao_2 VARCHAR(30),
    apelido VARCHAR(30),
    -- 'M': Macho, 'F': Fêmea e 'I': Indeterminado.
    sexo CHAR(1),
    -- 'S': Pertence ao plantel, 'N': Não pertence.
    plantel VARCHAR(30) NOT NULL,
    nro_gefau VARCHAR(30),
    nro_livro INTEGER NOT NULL,

    CONSTRAINT pk_animal PRIMARY KEY(nro_reg),
    CONSTRAINT uk1_animal_nro_gefau UNIQUE(nro_gefau),
    CONSTRAINT uk2_animal_nro_livro UNIQUE(nro_livro),
    CONSTRAINT ck_animal_sexo CHECK(sexo IN ('M', 'F', 'I')),
    CONSTRAINT ck_animal_plantel CHECK(plantel IN ('S', 'N')),
    CONSTRAINT ck_animal_data_nasc CHECK(data_nasc <= CURRENT_DATE),
    CONSTRAINT fk_animal_especie FOREIGN KEY(especie)
        REFERENCES especie(nome_cientifico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE triagem (
    animal INTEGER NOT NULL,
    data_triagem DATE NOT NULL,
    peso_ao_chegar NUMERIC(7,3),
    score_corporal INTEGER,
    gravidade_veterinaria VARCHAR(30),
    observacoes VARCHAR(50),
    idade_na_triagem INTEGER,

    CONSTRAINT pk_triagem PRIMARY KEY(animal, data_triagem),
    CONSTRAINT ck_triagem_score CHECK (score_corporal BETWEEN 1 AND 5),
    CONSTRAINT ck_triagem_data CHECK (data_triagem <= CURRENT_DATE),
    CONSTRAINT fk_triagem_animal FOREIGN KEY(animal)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE restricoes (
    animal INTEGER NOT NULL,
    data_triagem DATE NOT NULL, 
    restricao VARCHAR(30) NOT NULL,

    CONSTRAINT pk_restricoes PRIMARY KEY(animal, data_triagem, restricao),
    CONSTRAINT fk_restricoes_triagem FOREIGN KEY(animal, data_triagem)
        REFERENCES triagem(animal, data_triagem)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE risco (
    animal INTEGER NOT NULL,
    data_triagem DATE NOT NULL,
    risco VARCHAR(30) NOT NULL,

    CONSTRAINT pk_risco PRIMARY KEY(animal, data_triagem, risco),
    CONSTRAINT fk_risco_triagem FOREIGN KEY(animal, data_triagem)
        REFERENCES triagem(animal, data_triagem)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE funcionario (
    -- Armazena-se apenas os numeros
    cpf CHAR(11) NOT NULL,
    nome VARCHAR(30),
    telefone VARCHAR(20),
    funcao VARCHAR(20) DEFAULT 'VISITANTE',

    CONSTRAINT pk_funcionario PRIMARY KEY(cpf),
    CONSTRAINT ck_func_cpf CHECK(LENGTH(cpf) = 11),
    CONSTRAINT ck_func_telefone CHECK(LENGTH(telefone) >= 8),
    CONSTRAINT ck_func_funcao CHECK (funcao IN ('ADMINISTRADOR', 'VETERINARIO', 'BIOLOGO', 'VISITANTE'))
);

CREATE TABLE registro_biologico (
    animal INTEGER NOT NULL,
    data_triagem DATE NOT NULL,
    data_hora_registro TIMESTAMP NOT NULL, -- Alterado para TIMESTAMP para guardar a hora
    ocorrencia VARCHAR(50),
    detalhamento VARCHAR(50),
    anexo_laudo_saude BYTEA, -- Equivalente Postgres para BLOB
    funcionario CHAR(11) NOT NULL,

    CONSTRAINT pk_registro_biologico PRIMARY KEY(animal, data_triagem, data_hora_registro),
    CONSTRAINT fk_regbiologico_triagem FOREIGN KEY(animal, data_triagem)
        REFERENCES triagem(animal, data_triagem)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_regbiologico_funcionario FOREIGN KEY(funcionario)
        REFERENCES funcionario(cpf)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE registro_clinico (
    id INTEGER NOT NULL,
    animal INTEGER NOT NULL,
    data_triagem DATE NOT NULL,
    data_hora_registro TIMESTAMP NOT NULL, -- Alterado para TIMESTAMP para guardar a hora
    ocorrencia VARCHAR(50) NOT NULL,
    tratamento VARCHAR(50),
    funcionario CHAR(11) NOT NULL,

    CONSTRAINT pk_registro_clinico PRIMARY KEY(id),
    CONSTRAINT uk_registro_clinico UNIQUE(animal, data_triagem, data_hora_registro),
    CONSTRAINT fk_regclinico_triagem FOREIGN KEY(animal, data_triagem)
        REFERENCES triagem(animal, data_triagem)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_regclinico_funcionario FOREIGN KEY(funcionario)
        REFERENCES funcionario(cpf)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE medicamento_administrado (
    id INTEGER NOT NULL,
    medicamento VARCHAR(30) NOT NULL,
    dose_pv NUMERIC(7,3),

    CONSTRAINT pk_medicamento_adm PRIMARY KEY(id, medicamento),
    CONSTRAINT fk_medicamento_adm_regclinico FOREIGN KEY(id)
        REFERENCES registro_clinico(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE exames (
    id INTEGER NOT NULL,
    data_exame DATE NOT NULL,
    tipo_exame VARCHAR(30),
    resultados VARCHAR(100),
    observacoes VARCHAR(50),

    CONSTRAINT pk_exames PRIMARY KEY(id, data_exame, tipo_exame),
    CONSTRAINT fk_exames_regclinico FOREIGN KEY(id)
        REFERENCES registro_clinico(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-----------------------------------------------------------------------
-------------------------- PARTE DANTE (REVISADA) ---------------------
-----------------------------------------------------------------------

CREATE TABLE recinto (
    recinto_gefau VARCHAR(30) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    capacidade_max INTEGER NOT NULL,
    qnt_animais INTEGER DEFAULT 0 NOT NULL,
    qnt_especies INTEGER DEFAULT 0 NOT NULL,

    CONSTRAINT pk_recinto PRIMARY KEY(recinto_gefau),
    CONSTRAINT ck_recinto_capacidade CHECK (qnt_animais <= capacidade_max)
);

CREATE TABLE alocacao (
    animal INTEGER NOT NULL,
    recinto VARCHAR(30) NOT NULL,
    data_entrada DATE NOT NULL,
    data_saida DATE,
    motivo_saida VARCHAR(100),

    CONSTRAINT pk_alocacao PRIMARY KEY(animal, recinto, data_entrada),
    CONSTRAINT fk_alocacao_animal FOREIGN KEY(animal)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_alocacao_recinto FOREIGN KEY(recinto)
        REFERENCES recinto(recinto_gefau)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT ck_alocacao_datas CHECK (data_saida IS NULL OR data_saida > data_entrada)
);

CREATE TABLE casal (
    animal_1 INTEGER NOT NULL,
    animal_2 INTEGER NOT NULL,

    CONSTRAINT pk_casal PRIMARY KEY(animal_1, animal_2),
    CONSTRAINT fk_casal_animal1 FOREIGN KEY(animal_1)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_casal_animal2 FOREIGN KEY(animal_2)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_casal_diferentes CHECK (animal_1 <> animal_2)
    -- Garantir via Trigger que o casal tenha mesma espécie.
);

CREATE TABLE prole (
    pai INTEGER NOT NULL,
    mae INTEGER NOT NULL,
    prole INTEGER NOT NULL,

    CONSTRAINT pk_prole PRIMARY KEY(prole),
    CONSTRAINT fk_prole_casal FOREIGN KEY(pai, mae)
        REFERENCES casal(animal_1, animal_2)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_prole_animal FOREIGN KEY(prole)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    -- Garantir via Trigger que a prole seja da mesma espécie dos pais.
);

CREATE TABLE item_cardapio (
    animal INTEGER NOT NULL,
    alimento VARCHAR(50) NOT NULL,
    quantidade NUMERIC(7,3),
    observacoes VARCHAR(100),
    frequencia VARCHAR(30),

    CONSTRAINT pk_item_cardapio PRIMARY KEY(animal, alimento),
    CONSTRAINT fk_item_cardapio_animal FOREIGN KEY(animal)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE descricao_rotina (
    animal INTEGER NOT NULL,
    tipo_rotina VARCHAR(20) NOT NULL,
    objetivo VARCHAR(100) NOT NULL,
    metodologia VARCHAR(500) NOT NULL,
    ferramentas VARCHAR(200),
    frequencia VARCHAR(30) NOT NULL,
    tipo VARCHAR(30),
    comandos VARCHAR(200),

    CONSTRAINT pk_descricao_rotina PRIMARY KEY(animal, tipo_rotina),
    CONSTRAINT fk_descricao_rotina_animal FOREIGN KEY(animal)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_desc_rotina_tipo CHECK (tipo_rotina IN ('Condicionamento', 'Enriquecimento'))
);

CREATE TABLE registro_rotina (
    animal INTEGER NOT NULL,
    tipo_rotina VARCHAR(20) NOT NULL,
    data_horario TIMESTAMP NOT NULL, -- Alterado para TIMESTAMP
    observacoes VARCHAR(100),
    dias_semana CHAR(7) NOT NULL,

    CONSTRAINT pk_registro_rotina PRIMARY KEY(animal, tipo_rotina, data_horario),
    CONSTRAINT fk_registro_rotina_desc FOREIGN KEY(animal, tipo_rotina)
        REFERENCES descricao_rotina(animal, tipo_rotina)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT ck_registro_rotina_dias CHECK (LENGTH(dias_semana) = 7 AND dias_semana ~ '^[01]{7}$') -- Adaptado para Regex do Postgres
);

CREATE TABLE documento (
    tipo_documento VARCHAR(50) NOT NULL,
    nro_documento VARCHAR(50) NOT NULL,
    animal INTEGER NOT NULL,
    anexo BYTEA NOT NULL, -- Equivalente Postgres para BLOB
    data_cadastro DATE NOT NULL,
    observacao VARCHAR(200),
    destino VARCHAR(50),
    origem VARCHAR(50),

    CONSTRAINT pk_documento PRIMARY KEY(tipo_documento, nro_documento),
    CONSTRAINT fk_documento_animal FOREIGN KEY(animal)
        REFERENCES animal(nro_reg)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
);