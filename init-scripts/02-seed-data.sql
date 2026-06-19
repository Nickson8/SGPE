-- =====================================================================
-- SGPE — Dados de demonstração (PostgreSQL)
-- =====================================================================
-- Baseado no sql/dados.sql original, porém REESCRITO para CONFORMAR ao
-- DDL normalizado (01-create-tables.sql) e EXPANDIDO para popular bem os
-- dashboards e as linhas do tempo do prontuário.
--
-- Por que reescrito e não apenas "traduzido": o sql/dados.sql original foi
-- escrito contra uma versão anterior do esquema e é INCOMPATÍVEL com o DDL
-- atual (nomes de colunas acentuados/diferentes, valores que violam os
-- CHECKs — ex.: Funcao 'Veterinário' vs 'VETERINARIO', PlanoDeManejo texto
-- livre vs 'S'/'N', DiasSemana 'Segunda-feira' vs binário, ScoreCorporal
-- texto vs FLOAT, NroLivro repetido vs UNIQUE/INTEGER). O DDL é o núcleo
-- imutável, então os dados foram ajustados para respeitá-lo, preservando os
-- mesmos animais/espécies/recintos no espírito do original.
--
-- Animais "destaque" (1 Juma, 3 Dengo, 8 Mancha, 13 Aurélio, 19 Tuco,
-- 27 Dentão) recebem várias triagens + registros + medicações + exames +
-- alertas, para que os gráficos de evolução e a timeline fiquem ricos.
-- =====================================================================

-- ── Espécies ──────────────────────────────────────────────────────────
INSERT INTO ESPECIE (NomeCientifico, NomeComum, GrupoTaxonomico, PlanaDeManejo, Quantidade) VALUES
('Panthera onca',            'Onça-pintada',       'Mamíferos', 'S', 4),
('Myrmecophaga tridactyla',  'Tamanduá-bandeira',  'Mamíferos', 'S', 3),
('Leopardus pardalis',       'Jaguatirica',        'Mamíferos', 'S', 3),
('Chrysocyon brachyurus',    'Lobo-guará',         'Mamíferos', 'S', 3),
('Tapirus terrestris',       'Anta',               'Mamíferos', 'S', 2),
('Alouatta caraya',          'Bugio-preto',        'Mamíferos', 'N', 2),
('Rhea americana',           'Ema',                'Aves',      'N', 3),
('Ramphastos toco',          'Tucano-toco',        'Aves',      'N', 2),
('Sarcoramphus papa',        'Urubu-rei',          'Aves',      'S', 1),
('Ara ararauna',             'Arara-canindé',      'Aves',      'N', 3),
('Caiman latirostris',       'Jacaré-de-papo',     'Répteis',   'N', 3),
('Chelonoidis carbonaria',   'Jabuti-piranga',     'Répteis',   'N', 2),
('Boa constrictor',          'Jiboia',             'Répteis',   'N', 3),
('Phyllomedusa bahiana',     'Perereca-macaco',    'Anfíbios',  'S', 2);

-- ── Recintos (QntAnimais reflete alocações ativas; <= CapacidadeMax) ───
INSERT INTO RECINTO (RecintoGEFAU, Nome, CapacidadeMax, QntAnimais, QntEspecies) VALUES
('REC-101', 'Recinto das Onças - Setor A',     6,  4, 1),
('REC-102', 'Mata dos Felinos - Setor A',      4,  3, 1),
('REC-202', 'Savana e Cerrado - Setor B',     12,  5, 3),
('REC-203', 'Vale dos Tamanduás',              4,  3, 1),
('REC-204', 'Campo dos Lobos',                 3,  3, 1),
('REC-301', 'Aviário Tropical',               20,  3, 2),
('REC-302', 'Viveiro das Araras',              4,  3, 1),
('REC-303', 'Recinto das Emas',                8,  2, 1),
('REC-401', 'Pântano dos Jacarés',             8,  3, 1),
('REC-402', 'Répteis e Quelônios',             4,  3, 2),
('REC-403', 'Casa dos Répteis',                2,  2, 1),
('REC-501', 'Anfibiário',                     30,  2, 1);

-- ── Funcionários ──────────────────────────────────────────────────────
INSERT INTO FUNCIONARIO (CPF, Nome, Telefone, Funcao) VALUES
('12345678901', 'Dr. Carlos Silva',  '16999990001', 'VETERINARIO'),
('98765432100', 'Dra. Ana Souza',    '16999990002', 'BIOLOGO'),
('11122233344', 'Dr. Rui Mendes',    '16999990003', 'VETERINARIO'),
('55566677788', 'Bia Antunes',       '16999990004', 'BIOLOGO'),
('99988877766', 'Marcos Diretor',    '16999990005', 'ADMINISTRADOR');

-- ── Animais ─────────────────────────────────────────────────────────────
-- (NroReg, Especie, DataNasc, Marcacao1, Marcacao2, Apelido, Sexo, Plantel, NroGEFAU, NroLivro)
INSERT INTO ANIMAL (NroReg, Especie, DataNasc, Marcacao1, Marcacao2, Apelido, Sexo, Plantel, NroGEFAU, NroLivro) VALUES
(1,  'Panthera onca',           '2020-05-12', 'CHIP-9810', 'BRINCO-01', 'Juma',     'F', 'S', 'GEFAU-001', 1001),
(2,  'Panthera onca',           '2019-08-20', 'CHIP-9820', 'BRINCO-02', 'Tufão',    'M', 'S', 'GEFAU-002', 1002),
(3,  'Myrmecophaga tridactyla', '2021-03-15', 'CHIP-1110', NULL,        'Dengo',    'M', 'S', 'GEFAU-003', 1003),
(4,  'Panthera onca',           '2025-01-10', 'CHIP-9830', NULL,        'Pipoca',   'F', 'S', 'GEFAU-004', 1004),
(5,  'Panthera onca',           '2025-01-10', 'CHIP-9840', NULL,        'Fumaça',   'M', 'S', 'GEFAU-005', 1005),
(6,  'Myrmecophaga tridactyla', '2018-02-10', 'CHIP-1120', NULL,        'Maya',     'F', 'S', 'GEFAU-006', 1006),
(7,  'Myrmecophaga tridactyla', '2017-11-25', 'CHIP-1130', NULL,        'Bore',     'M', 'S', 'GEFAU-007', 1007),
(8,  'Leopardus pardalis',      '2019-04-03', 'CHIP-2210', NULL,        'Mancha',   'F', 'S', 'GEFAU-008', 1008),
(9,  'Leopardus pardalis',      '2020-09-17', 'CHIP-2220', NULL,        'Pingo',    'M', 'S', 'GEFAU-009', 1009),
(10, 'Leopardus pardalis',      '2018-12-01', 'CHIP-2230', NULL,        'Tigrão',   'M', 'S', 'GEFAU-010', 1010),
(11, 'Tapirus terrestris',      '2016-07-22', 'CHIP-3310', NULL,        'Maité',    'F', 'S', 'GEFAU-011', 1011),
(12, 'Tapirus terrestris',      '2015-03-30', 'CHIP-3320', NULL,        'Tonico',   'M', 'S', 'GEFAU-012', 1012),
(13, 'Chrysocyon brachyurus',   '2019-06-14', 'CHIP-4410', NULL,        'Aurélio',  'M', 'S', 'GEFAU-013', 1013),
(14, 'Chrysocyon brachyurus',   '2020-02-08', 'CHIP-4420', NULL,        'Serena',   'F', 'S', 'GEFAU-014', 1014),
(15, 'Chrysocyon brachyurus',   '2022-10-19', 'CHIP-4430', NULL,        'Caçula',   'M', 'S', 'GEFAU-015', 1015),
(16, 'Alouatta caraya',         '2018-05-05', 'CHIP-5510', NULL,        'Saruê',    'M', 'S', 'GEFAU-016', 1016),
(17, 'Alouatta caraya',         '2019-11-11', 'CHIP-5520', NULL,        'Lua',      'F', 'S', 'GEFAU-017', 1017),
(18, 'Rhea americana',          '2017-08-08', 'ANILHA-01', NULL,        'Pernalonga','M','S', 'GEFAU-018', 1018),
(19, 'Ramphastos toco',         '2021-01-20', 'ANILHA-02', NULL,        'Tuco',     'M', 'S', 'GEFAU-019', 1019),
(20, 'Ramphastos toco',         '2021-01-25', 'ANILHA-03', NULL,        'Bica',     'F', 'S', 'GEFAU-020', 1020),
(21, 'Sarcoramphus papa',       '2016-04-17', 'ANILHA-04', NULL,        'Rei',      'M', 'S', 'GEFAU-021', 1021),
(22, 'Ara ararauna',            '2020-07-07', 'ANILHA-05', NULL,        'Azulão',   'M', 'S', 'GEFAU-022', 1022),
(23, 'Ara ararauna',            '2020-07-09', 'ANILHA-06', NULL,        'Céu',      'F', 'S', 'GEFAU-023', 1023),
(24, 'Ara ararauna',            '2019-03-03', 'ANILHA-07', NULL,        'Tango',    'M', 'S', 'GEFAU-024', 1024),
(25, 'Rhea americana',          '2018-09-09', 'ANILHA-08', NULL,        'Ester',    'F', 'S', 'GEFAU-025', 1025),
(26, 'Rhea americana',          '2017-12-12', 'ANILHA-09', NULL,        'Gigante',  'M', 'S', 'GEFAU-026', 1026),
(27, 'Caiman latirostris',      '2014-06-06', 'TAG-J-01',  NULL,        'Dentão',   'M', 'S', 'GEFAU-027', 1027),
(28, 'Caiman latirostris',      '2015-10-10', 'TAG-J-02',  NULL,        'Lola',     'F', 'S', 'GEFAU-028', 1028),
(29, 'Caiman latirostris',      '2016-02-02', 'TAG-J-03',  NULL,        'Couro',    'M', 'S', 'GEFAU-029', 1029),
(30, 'Chelonoidis carbonaria',  '2005-05-05', 'TAG-Q-01',  NULL,        'Casco',    'M', 'S', 'GEFAU-030', 1030),
(31, 'Chelonoidis carbonaria',  '2008-08-08', 'TAG-Q-02',  NULL,        'Lenta',    'F', 'S', 'GEFAU-031', 1031),
(32, 'Boa constrictor',         '2019-09-19', 'TAG-S-01',  NULL,        'Naja',     'F', 'S', 'GEFAU-032', 1032),
(33, 'Boa constrictor',         '2018-04-24', 'TAG-S-02',  NULL,        'Anaconda', 'M', 'S', 'GEFAU-033', 1033),
(34, 'Boa constrictor',         '2020-11-30', 'TAG-S-03',  NULL,        'Pítia',    'F', 'S', 'GEFAU-034', 1034),
(35, 'Phyllomedusa bahiana',    '2023-03-21', 'TAG-A-01',  NULL,        'Verdinha', 'F', 'S', 'GEFAU-035', 1035),
(36, 'Phyllomedusa bahiana',    '2023-03-21', 'TAG-A-02',  NULL,        'Saltão',   'M', 'S', 'GEFAU-036', 1036);

-- ── Alocações (atuais: DataSaida NULL; + alguns históricos) ────────────
INSERT INTO ALOCACAO (Animal, Recinto, DataEntrada, DataSaida, MotivoSaida) VALUES
-- atuais
(1,  'REC-101', '2021-01-15', NULL, NULL),
(2,  'REC-101', '2021-01-15', NULL, NULL),
(4,  'REC-101', '2025-02-01', NULL, NULL),
(5,  'REC-101', '2025-02-01', NULL, NULL),
(8,  'REC-102', '2020-03-10', NULL, NULL),
(9,  'REC-102', '2021-05-20', NULL, NULL),
(10, 'REC-102', '2019-06-01', NULL, NULL),
(3,  'REC-203', '2022-06-10', NULL, NULL),
(6,  'REC-203', '2019-01-05', NULL, NULL),
(7,  'REC-203', '2018-07-15', NULL, NULL),
(11, 'REC-202', '2017-02-12', NULL, NULL),
(12, 'REC-202', '2016-09-01', NULL, NULL),
(16, 'REC-202', '2019-01-30', NULL, NULL),
(17, 'REC-202', '2020-04-04', NULL, NULL),
(18, 'REC-202', '2018-03-18', NULL, NULL),
(13, 'REC-204', '2020-01-10', NULL, NULL),
(14, 'REC-204', '2021-03-22', NULL, NULL),
(15, 'REC-204', '2023-02-14', NULL, NULL),
(19, 'REC-301', '2021-03-01', NULL, NULL),
(20, 'REC-301', '2021-03-01', NULL, NULL),
(21, 'REC-301', '2017-05-05', NULL, NULL),
(22, 'REC-302', '2021-01-01', NULL, NULL),
(23, 'REC-302', '2021-01-01', NULL, NULL),
(24, 'REC-302', '2020-08-08', NULL, NULL),
(25, 'REC-303', '2019-02-02', NULL, NULL),
(26, 'REC-303', '2018-06-06', NULL, NULL),
(27, 'REC-401', '2015-01-01', NULL, NULL),
(28, 'REC-401', '2016-03-03', NULL, NULL),
(29, 'REC-401', '2017-07-07', NULL, NULL),
(30, 'REC-402', '2010-01-01', NULL, NULL),
(31, 'REC-402', '2012-04-04', NULL, NULL),
(32, 'REC-402', '2020-02-20', NULL, NULL),
(33, 'REC-403', '2019-05-05', NULL, NULL),
(34, 'REC-403', '2021-09-09', NULL, NULL),
(35, 'REC-501', '2023-06-01', NULL, NULL),
(36, 'REC-501', '2023-06-01', NULL, NULL),
-- históricos (transferências passadas)
(1,  'REC-102', '2020-06-01', '2021-01-14', 'Transferência para recinto definitivo'),
(13, 'REC-202', '2019-07-01', '2019-12-20', 'Realocação por reforma do recinto');

-- ── Triagens ───────────────────────────────────────────────────────────
-- Destaques com série temporal (peso/score) para os gráficos.
INSERT INTO TRIAGEM (Animal, DataTriagem, PesoAoChegar, ScoreCorporal, GravidadeVeterinaria, Observacoes, IdadeNaTriagem) VALUES
-- Juma (1) - onça
(1, '2025-01-15', 78.0, 3.0, 'Normal',  'Triagem de entrada anual',          4),
(1, '2025-04-15', 80.5, 3.5, 'Normal',  'Ganho de peso adequado',            5),
(1, '2025-07-15', 82.0, 3.5, 'Normal',  'Avaliação semestral',               5),
(1, '2025-10-15', 84.2, 4.0, 'Normal',  'Condição corporal ideal',           5),
(1, '2026-01-15', 85.4, 4.0, 'Normal',  'Avaliação periódica semestral',     6),
(1, '2026-04-15', 86.1, 4.0, 'Normal',  'Estável',                           6),
-- Dengo (3) - tamanduá
(3, '2025-02-02', 30.5, 2.5, 'Alerta',  'Abaixo do peso na entrada',         4),
(3, '2025-05-02', 33.0, 3.0, 'Normal',  'Resposta positiva à dieta',         4),
(3, '2025-08-02', 35.4, 3.0, 'Normal',  'Evolução satisfatória',             4),
(3, '2025-11-02', 37.1, 3.5, 'Normal',  'Peso recuperado',                   4),
(3, '2026-02-02', 38.2, 3.5, 'Alerta',  'Leve apatia alimentar',             5),
-- Mancha (8) - jaguatirica
(8, '2025-03-10', 11.2, 3.0, 'Normal',  'Triagem anual',                     5),
(8, '2025-09-10', 11.8, 3.5, 'Normal',  'Avaliação semestral',               6),
(8, '2026-03-10', 12.1, 3.5, 'Normal',  'Condição estável',                  6),
-- Aurélio (13) - lobo-guará
(13, '2025-01-20', 23.0, 3.0, 'Normal', 'Triagem de entrada',                5),
(13, '2025-07-20', 24.5, 3.5, 'Normal', 'Pelagem em ótimo estado',           5),
(13, '2026-01-20', 25.2, 3.5, 'Normal', 'Avaliação anual',                   6),
-- Tuco (19) - tucano
(19, '2025-02-05',  0.55, 3.0, 'Normal', 'Triagem do plantel de aves',       4),
(19, '2025-08-05',  0.58, 3.5, 'Normal', 'Bico íntegro',                     4),
(19, '2026-02-05',  0.60, 3.5, 'Normal', 'Estável',                          5),
-- Dentão (27) - jacaré
(27, '2025-01-08', 42.0, 4.0, 'Normal', 'Triagem do setor de répteis',       10),
(27, '2025-07-08', 43.5, 4.0, 'Normal', 'Avaliação semestral',               11),
(27, '2026-01-08', 44.8, 4.0, 'Alerta', 'Pequena lesão de pele observada',   11),
-- Triagens pontuais para variar a base
(2,  '2026-01-15', 92.0, 4.0, 'Normal', 'Triagem anual',                     6),
(6,  '2026-02-10', 36.0, 3.5, 'Normal', 'Triagem anual',                     8),
(7,  '2026-02-10', 40.5, 4.0, 'Normal', 'Triagem anual',                     8),
(11, '2026-03-12', 210.0,4.0, 'Normal', 'Triagem anual da anta',             9),
(22, '2026-01-30',  1.05,3.5, 'Normal', 'Triagem das araras',                5),
(30, '2026-02-15', 18.4, 4.0, 'Normal', 'Triagem dos quelônios',             21);

-- ── Restrições (referência: TRIAGEM(Animal, DataTriagem); <= 30 chars) ──
INSERT INTO RESTRICOES (Animal, DataTriagem, Restricao) VALUES
(3,  '2026-02-02', 'Evitar itens rigidos 48h'),
(3,  '2025-02-02', 'Dieta pastosa supervisionada'),
(27, '2026-01-08', 'Manejo com contencao fisica'),
(1,  '2026-01-15', 'Sem restricoes ativas');

-- ── Riscos (referência: TRIAGEM(Animal, DataTriagem); <= 30 chars) ──────
INSERT INTO RISCO (Animal, DataTriagem, Risco) VALUES
(1,  '2026-01-15', 'Baixo - habituado a contencao'),
(3,  '2026-02-02', 'Medio - apatia alimentar'),
(27, '2026-01-08', 'Alto - lesao de pele'),
(13, '2026-01-20', 'Baixo - animal docil');

-- ── Registros clínicos (ID único; ref TRIAGEM existente) ────────────────
INSERT INTO REGISTROCLINICO (ID, Animal, DataTriagem, DataHoraRegistro, Ocorrencia, Tratamento, Funcionario) VALUES
(101, 1,  '2026-01-15', '2026-01-15 11:30:00', 'Vacinação anual',            'Reforço vacinal tríplice felina',     '12345678901'),
(102, 3,  '2026-02-02', '2026-02-02 10:00:00', 'Tratamento de endoparasitas','Vermífugo oral de amplo espectro',    '12345678901'),
(103, 3,  '2025-05-02', '2025-05-02 09:00:00', 'Suporte nutricional',        'Suplementação vitamínica',            '98765432100'),
(104, 8,  '2026-03-10', '2026-03-10 14:00:00', 'Avaliação dermatológica',    'Pomada cicatrizante tópica',          '11122233344'),
(105, 13, '2026-01-20', '2026-01-20 08:45:00', 'Vermifugação preventiva',    'Antiparasitário oral',                '12345678901'),
(106, 27, '2026-01-08', '2026-01-08 16:20:00', 'Sutura de lesão cutânea',    'Antibiótico e curativo',              '11122233344'),
(107, 1,  '2025-07-15', '2025-07-15 10:15:00', 'Exame odontológico',         'Limpeza dentária sob sedação',        '12345678901');

-- ── Medicamentos administrados (ref REGISTROCLINICO.ID; DosePV numérico mL/dose) ──
INSERT INTO MEDICAMENTOADMINISTRADO (ID, Medicamento, DosePV) VALUES
(101, 'Nobivac Triplice Felina', 1.0),
(102, 'Praziquantel',            2.5),
(102, 'Pirantel',                1.5),
(103, 'Complexo Vitaminico B',   5.0),
(104, 'Cefalexina',              3.0),
(105, 'Ivermectina',             0.8),
(106, 'Enrofloxacina',           4.0),
(106, 'Meloxicam',               0.5),
(107, 'Cetamina',                2.0);

-- ── Exames (ref REGISTROCLINICO.ID) ─────────────────────────────────────
INSERT INTO EXAMES (ID, DataExame, TipoExame, Resultados, Observacoes) VALUES
(101, '2026-01-15', 'Sorologia FIV/FeLV',   'Negativo para FIV e FeLV',                'Preventivo padrão'),
(101, '2026-01-16', 'Hemograma completo',   'Parâmetros dentro da normalidade',        'Sem alterações'),
(102, '2026-02-05', 'Coprológico controle', 'Ausência de ovos e oocistos',             'Pós-tratamento'),
(104, '2026-03-11', 'Citologia de pele',    'Processo inflamatório leve',              'Reavaliar em 15 dias'),
(106, '2026-01-09', 'Raspado de lesão',     'Sem agente infeccioso identificado',      'Cicatrização em curso'),
(107, '2025-07-15', 'Radiografia de crânio','Sem fraturas; tártaro moderado',          'Indicada profilaxia');

-- ── Registros biológicos (ref TRIAGEM(Animal, DataTriagem) + FUNCIONARIO) ──
INSERT INTO REGISTROBIOLOGICO (Animal, DataTriagem, DataHoraRegistro, Ocorrencia, Detalhamento, AnexoLaudoSaude, Funcionario) VALUES
(1,  '2026-01-15', '2026-01-15 11:00:00', 'Coleta de sangue de rotina', 'Veia cefálica para hemograma',     convert_to('laudo_hemograma_juma.pdf','UTF8'), '98765432100'),
(3,  '2026-02-02', '2026-02-02 09:15:00', 'Coleta de material fecal',   'Análise coprológica solicitada',   convert_to('laudo_copro_dengo.pdf','UTF8'),    '98765432100'),
(13, '2026-01-20', '2026-01-20 09:30:00', 'Avaliação comportamental',   'Etograma de 30 minutos',           convert_to('etograma_aurelio.pdf','UTF8'),     '55566677788'),
(27, '2026-01-08', '2026-01-08 15:00:00', 'Biometria do plantel',       'Medição de comprimento total',     convert_to('biometria_dentao.pdf','UTF8'),     '55566677788');

-- ── Casais ──────────────────────────────────────────────────────────────
INSERT INTO CASAL (Animal_1, Animal_2) VALUES
(2, 1),   -- Tufão e Juma
(7, 6),   -- Bore e Maya
(12, 11); -- Tonico e Maité

-- ── Prole (ref CASAL(Pai,Mae) -> (Animal_1,Animal_2); ref ANIMAL(Prole)) ──
INSERT INTO PROLE (Pai, Mae, Prole) VALUES
(2, 1, 4),  -- Tufão + Juma -> Pipoca
(2, 1, 5);  -- Tufão + Juma -> Fumaça

-- ── Itens de cardápio ─────────────────────────────────────────────────────
INSERT INTO ITEMCARDAPIO (Animal, Alimento, Quantidade, Observacoes, Frequencia) VALUES
(1, 'Carne bovina com osso',          5.5, 'Oferecer no final da tarde',                 'Diário'),
(3, 'Suplemento de insetos batido',   2.0, 'Adicionar complexo vitamínico',              'Duas vezes ao dia'),
(8, 'Carne magra e frango',           1.2, 'Dieta de felino de pequeno porte',           'Diário'),
(27,'Peixe e carne vermelha',         3.0, 'Oferta em dias alternados',                  'Dia sim, dia não');

-- ── Descrições de rotina (TipoRotina: 'Condicionamento' | 'Enriquecimento') ──
INSERT INTO DESCRICAOROTINA (Animal, TipoRotina, Objetivo, Metodologia, Ferramentas, Frequencia, Tipo, Comandos) VALUES
(1,  'Enriquecimento', 'Estimular comportamento de caça', 'Esconder porções de carne em caixas suspensas', 'Caixas de papelão, cordas de sisal', 'Semanal', 'Cognitivo/Alimentar', NULL),
(3,  'Condicionamento','Exercício físico e desgaste de garras', 'Conduzir o animal em área gramada controlada', 'Guia peitoral adaptada', '3 vezes por semana', NULL, 'Vem, fica, anda'),
(13, 'Enriquecimento', 'Reduzir comportamento estereotipado', 'Distribuir frutas em pontos variados do recinto', 'Comedouros móveis', 'Diário', 'Alimentar', NULL);

-- ── Registros de rotina (ref DESCRICAOROTINA; DiasSemana binário CHAR(7)) ──
INSERT INTO REGISTROROTINA (Animal, TipoRotina, DataHorario, Observacoes, DiasSemana) VALUES
(1,  'Enriquecimento',  '2026-01-19 10:00:00', 'Interagiu com o estímulo por 25 minutos', '1000000'),
(3,  'Condicionamento', '2026-01-20 08:30:00', 'Bom ritmo, explorou troncos caídos',      '1010100'),
(13, 'Enriquecimento',  '2026-01-21 09:00:00', 'Forrageou em todos os pontos',            '1111111');

-- ── Documentos (Anexo BYTEA NOT NULL; consistência de migração) ─────────
INSERT INTO DOCUMENTO (TipoDocumento, NroDocumento, Animal, Anexo, DataCadastro, Observacao, TipoMigracao, Destino, Origem) VALUES
('Termo de Transferência', 'DOC-9921-A', 1,  convert_to('termo_juma.pdf','UTF8'),       '2021-01-10', 'Cedida pelo Zoológico de São Paulo',  'Entrada', NULL, 'Zoológico de São Paulo'),
('Laudo de Nascimento',    'DOC-1122-B', 3,  convert_to('laudo_nasc_dengo.pdf','UTF8'), '2021-03-15', 'Nascido em cativeiro autorizado',     'Entrada', NULL, 'Maternidade BioParque'),
('Laudo de Necrópsia',     'DOC-3030-C', 30, convert_to('laudo_casco.pdf','UTF8'),      '2024-05-01', 'Documento clínico comum',             NULL,      NULL, NULL);
