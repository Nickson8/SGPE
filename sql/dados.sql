-- Tabela: especie
INSERT INTO especie (nome_cientifico, nome_comum, grupo_taxonomico, plano_de_manejo, quantidade) VALUES
    ('Panthera onca',            'Onça-pintada',     'Mamíferos', 'S', 5),
    ('Myrmecophaga tridactyla',  'Tamanduá-bandeira', 'Mamíferos', 'S', 3);

-- Tabela: recinto
INSERT INTO recinto (recinto_gefau, nome, capacidade_max, qnt_animais, qnt_especies) VALUES
    ('REC-101', 'Recinto das Onças - Setor A',  6, 4, 1),
    ('REC-202', 'Savana e Cerrado - Setor B',  12, 3, 2);

-- Tabela: funcionario
INSERT INTO funcionario (cpf, nome, telefone, funcao) VALUES
    ('12345678901', 'Dr. Carlos Silva', '16999999991', 'VETERINARIO'),
    ('98765432100', 'Dra. Ana Souza',   '16999999992', 'BIOLOGO');

-- Tabela: animal
INSERT INTO animal (nro_reg, especie, data_nasc, marcacao_1, marcacao_2, apelido, sexo, plantel, nro_gefau, nro_livro) VALUES
    (1, 'Panthera onca',           '2020-05-12', 'CHIP-9810', 'BRINCO-01', 'Juma',   'F', 'S', 'GEFAU-A10', 1),
    (2, 'Panthera onca',           '2019-08-20', 'CHIP-9820', 'BRINCO-02', 'Tufão',  'M', 'S', 'GEFAU-A11', 2),
    (3, 'Myrmecophaga tridactyla', '2021-03-15', 'CHIP-1110', NULL,        'Dengo',  'M', 'S', 'GEFAU-B01', 3),
    (4, 'Panthera onca',           '2025-01-10', 'CHIP-9830', NULL,        'Pipoca', 'F', 'N', 'GEFAU-A12', 4),
    (5, 'Panthera onca',           '2025-01-10', 'CHIP-9840', NULL,        'Fumaça', 'M', 'N', 'GEFAU-A13', 5),
    (6, 'Myrmecophaga tridactyla', '2018-02-10', 'CHIP-1120', NULL,        'Maya',   'F', 'S', 'GEFAU-B02', 6),
    (7, 'Myrmecophaga tridactyla', '2017-11-25', 'CHIP-1130', NULL,        'Bore',   'M', 'S', 'GEFAU-B03', 7);

-- Tabela: casal
INSERT INTO casal (animal_1, animal_2) VALUES
    (2, 1),  -- Tufão e Juma
    (7, 6);  -- Bore e Maya

-- Tabela: prole
INSERT INTO prole (pai, mae, prole) VALUES
    (2, 1, 4),  -- Pai: Tufão (2), Mãe: Juma (1) -> Pipoca (4)
    (2, 1, 5);  -- Pai: Tufão (2), Mãe: Juma (1) -> Fumaça (5)

-- Tabela: item_cardapio
INSERT INTO item_cardapio (animal, alimento, quantidade, observacoes, frequencia) VALUES
    (1, 'Carne Bovina com Osso',         5.500, 'Oferecer preferencialmente no final da tarde',                    'Diário'),
    (3, 'Suplemento de Insetos Batido',  2.000, 'Adicionar complexo vitamínico conforme instrução da bióloga',    'Duas vezes ao dia');

-- Tabela: descricao_rotina
INSERT INTO descricao_rotina (animal, tipo_rotina, objetivo, metodologia, ferramentas, frequencia, tipo, comandos) VALUES
    (1, 'Enriquecimento',
        'Estimular comportamento cognitivo e de caça',
        'Esconder porções de carne dentro de caixas de papelão suspensas',
        'Caixas de papelão, cordas de sisal',
        'Semanal',
        'Cognitivo/Alimentar',
        NULL),
    (1, 'Condicionamento',
        'Reforçar resposta a comandos básicos de manejo',
        'Associar sons de apito a recompensas alimentares em área controlada',
        'Apito, protetor de barreira, luvas de couro',
        'Três vezes por semana',
        NULL,
        'Apito-curto: aproximar; Apito-longo: recuar'),
    (3, 'Enriquecimento',
        'Exercício físico e desgaste natural das garras',
        'Conduzir o animal em área gramada externa controlada',
        'Guia peitoral adaptada',
        'Três vezes por semana',
        'Físico',
        NULL),
    (3, 'Condicionamento',
        'Habituar o animal à presença dos tratadores e ao peitoral',
        'Aproximação gradual com reforço positivo usando alimento',
        'Luvas de proteção, alimento palatável',
        'Diário',
        NULL,
        'Mão-aberta: parar; Dois-dedos: sentar');

-- Tabela: alocacao
INSERT INTO alocacao (animal, recinto, data_entrada, data_saida, motivo_saida) VALUES
    (1, 'REC-101', '2021-01-15', NULL, NULL),
    (2, 'REC-101', '2020-03-10', NULL, NULL),
    (3, 'REC-202', '2022-06-10', NULL, NULL),
    (6, 'REC-202', '2019-05-20', NULL, NULL),
    (7, 'REC-202', '2018-04-01', NULL, NULL);

-- Tabela: documento
-- anexo: BYTEA — usamos '\x00' como placeholder (arquivo binário)
INSERT INTO documento (tipo_documento, nro_documento, animal, anexo, data_cadastro, observacao, tipo_migracao, destino, origem) VALUES
    ('Termo de Transferência', 'DOC-9921-A', 1,
        '\x00'::BYTEA, '2021-01-10',
        'Cedida pelo Zoológico de São Paulo',
        'Entrada', NULL, 'Zoológico de São Paulo'),
    ('Laudo de Nascimento',    'DOC-1122-B', 3,
        '\x00'::BYTEA, '2021-03-15',
        'Nascido em cativeiro autorizado',
        'Entrada', NULL, 'Maternidade Veterinária BioParque');

-- Tabela: triagem
INSERT INTO triagem (animal, data_triagem, peso_ao_chegar, score_corporal, gravidade_veterinaria, observacoes, idade_na_triagem) VALUES
    (1, '2026-06-01', 85.400, 4, 'Normal', 'Avaliação periódica semestral',                       6),
    (3, '2026-06-02', 38.200, 2, 'Alerta', 'Triagem realizada após relato de leve apatia alimentar', 5);

-- Tabela: restricoes
INSERT INTO restricoes (animal, data_triagem, restricao) VALUES
    (1, '2026-06-01', 'Nenhuma restrição identificada'),
    (3, '2026-06-02', 'Evitar itens rígidos por 48h — desgaste na dentição');

-- Tabela: risco
INSERT INTO risco (animal, data_triagem, risco) VALUES
    (1, '2026-06-01', 'Baixo — habituado a contenção química'),
    (3, '2026-06-02', 'Médio — risco de ferimentos por garras na contenção física');

-- Tabela: registro_biologico
INSERT INTO registro_biologico (animal, data_triagem, data_hora_registro, ocorrencia, detalhamento, anexo_laudo_saude, funcionario) VALUES
    (1, '2026-06-01', '2026-06-01 11:00:00',
        'Coleta de Sangue de Rotina',
        'Coletado sangue da veia cefálica para hemograma completo.',
        NULL,
        '98765432100'),
    (3, '2026-06-02', '2026-06-02 09:15:00',
        'Coleta de Material Fecal',
        'Análise parasitológica coprológica solicitada.',
        NULL,
        '98765432100');

-- Tabela: registro_clinico
INSERT INTO registro_clinico (id, animal, data_triagem, data_hora_registro, ocorrencia, tratamento, funcionario) VALUES
    (101, 1, '2026-06-01', '2026-06-01 11:30:00',
        'Vacinação Anual',
        'Aplicação de reforço vacinal tríplice felina.',
        '12345678901'),
    (102, 3, '2026-06-02', '2026-06-02 10:00:00',
        'Tratamento de Endoparasitas',
        'Administração de vermífugo oral de amplo espectro.',
        '12345678901');

-- Tabela: medicamento_administrado
INSERT INTO medicamento_administrado (id, medicamento, dose_pv) VALUES
    (101, 'Vacina Tríplice Felina Nobivac',    1.000),
    (102, 'Vermífugo Praziquantel/Pirantel',   0.100);

-- Tabela: exames
INSERT INTO exames (id, data_exame, tipo_exame, resultados, observacoes) VALUES
    (101, '2026-06-01', 'Sorologia Preventiva',
        'Negativo para FIV/FeLV',
        'Procedimento preventivo padrão'),
    (102, '2026-06-05', 'Coprológico de Controle',
        'Ausência de ovos ou oocistos',
        'Exame pós-tratamento para certificar eficácia');

-- Tabela: registro_rotina
INSERT INTO registro_rotina (animal, tipo_rotina, data_horario, observacoes, dias_semana) VALUES
    (1, 'Enriquecimento', '2026-06-15 10:00:00',
        'Interagiu com o estímulo por 25 min até acessar o alimento.',
        '0100000'),  -- Segunda-feira
    (1, 'Condicionamento', '2026-06-17 09:00:00',
        'Respondeu corretamente ao apito em 3 de 4 tentativas.',
        '0010000'),  -- Terça-feira
    (3, 'Enriquecimento', '2026-06-16 08:30:00',
        'Explorou ativamente os troncos caídos durante a caminhada.',
        '0100000'),  -- Segunda-feira
    (3, 'Condicionamento', '2026-06-18 07:45:00',
        'Aceitou peitoral sem resistência pela primeira vez.',
        '0010000');  -- Quarta-feira