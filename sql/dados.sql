-- SCRIPT DE POPULAÇÃO INICIAL DO BANCO

-- Tabela: Espécie
INSERT INTO Especie (NomeCientifico, NomeComum, GrupoTaxonomico, PlanoDeManejo, Quantidade) VALUES
('Panthera onca', 'Onça-pintada', 'Mamíferos', 'Plano de Manejo e Conservação de Grandes Felinos', 5),
('Myrmecophaga tridactyla', 'Tamanduá-bandeira', 'Mamíferos', 'Plano de Conservação de Xenartros', 3);

-- Tabela: Recinto
INSERT INTO Recinto (RecintoGEFAU, Nome, CapMaxima, QntAnimais, QntEspecies) VALUES
('REC-101', 'Recinto das Onças - Setor A', 6, 4, 1),
('REC-202', 'Savana e Cerrado - Setor B', 12, 3, 2);

-- Tabela: Funcionário
INSERT INTO Funcionario (CPF, Nome, Telefone, Função) VALUES
('12345678901', 'Dr. Carlos Silva', '16999999991', 'Veterinário'),
('98765432100', 'Dra. Ana Souza', '16999999992', 'Bióloga');

-- Tabela: Animal
INSERT INTO Animal (NroReg, Espécie, DataNasc, Marcação_1, Marcação_2, Apelido, Sexo, Plantel, NroGEFAU, NroLivro) VALUES
(1, 'Panthera onca', '2020-05-12', 'CHIP-9810', 'BRINCO-01', 'Juma', 'F', 'Plantel Principal', 'GEFAU-A10', 'Livro-01'),
(2, 'Panthera onca', '2019-08-20', 'CHIP-9820', 'BRINCO-02', 'Tufão', 'M', 'Plantel Principal', 'GEFAU-A11', 'Livro-01'),
(3, 'Myrmecophaga tridactyla', '2021-03-15', 'CHIP-1110', NULL, 'Dengo', 'M', 'Plantel Principal', 'GEFAU-B01', 'Livro-02'),
(4, 'Panthera onca', '2025-01-10', 'CHIP-9830', NULL, 'Pipoca', 'F', 'Filhotes', 'GEFAU-A12', 'Livro-01'),
(5, 'Panthera onca', '2025-01-10', 'CHIP-9840', NULL, 'Fumaça', 'M', 'Filhotes', 'GEFAU-A13', 'Livro-01'),
(6, 'Myrmecophaga tridactyla', '2018-02-10', 'CHIP-1120', NULL, 'Maya', 'F', 'Plantel Principal', 'GEFAU-B02', 'Livro-02'),
(7, 'Myrmecophaga tridactyla', '2017-11-25', 'CHIP-1130', NULL, 'Bore', 'M', 'Plantel Principal', 'GEFAU-B03', 'Livro-02');

-- Tabela: Prole
INSERT INTO Prole (Pai, Mãe, Prole) VALUES
(2, 1, 4), -- Pai: Tufão (2), Mãe: Juma (1) -> Filho: Pipoca (4)
(2, 1, 5); -- Pai: Tufão (2), Mãe: Juma (1) -> Filho: Fumaça (5)

-- Tabela: Casal
INSERT INTO Casal (Animal_1, Animal_2) VALUES
(2, 1), -- Tufão e Juma
(7, 6); -- Bore e Maya

-- Tabela: ItemCardápio
INSERT INTO ItemCardapio (Animal, Alimento, QntPorção, Observações, Frequência) VALUES
(1, 'Carne Bovina com Osso', 5.5, 'Oferecer preferencialmente no final da tarde', 'Diário'),
(3, 'Suplemento de Insetos Batido', 2.0, 'Adicionar complexo vitamínico conforme instrução da bióloga', 'Duas vezes ao dia');

-- Tabela: DescriçãoRotina
INSERT INTO DescricaoRotina (Animal, TipoRotina, Objetivo, Metodologia, Ferramentas, Tipo, Comentários, Frequência) VALUES
(1, 'Enriquecimento Ambiental', 'Estimular comportamento cognitivo e de caça', 'Esconder porções de carne dentro de caixas de papelão suspensas', 'Caixas de papelão, cordas de sisal', 'Cognitivo/Alimentar', 'Animal apresenta excelente engajamento', 'Semanal'),
(3, 'Caminhada Monitorada', 'Exercício físico e desgaste natural das garras', 'Conduzir o animal em área gramada externa controlada', 'Guia peitoral adaptada', 'Físico', 'Realizar somente em horários de temperatura amena', '3 vezes por semana');

-- Tabela: Alocação
INSERT INTO Alocacao (Animal, Recinto, DataEntrada, DataSaída, MotivoSaída) VALUES
(1, 'REC-101', '2021-01-15', NULL, NULL),
(3, 'REC-202', '2022-06-10', NULL, NULL);

-- Tabela: Documento
INSERT INTO Documento (Animal, TipoDocumento, NroDocumento, Anexo, Data, Observação, TipoMigração, Destino, Origem) VALUES
(1, 'Termo de Transferência', 'DOC-9921-A', 'termo_juma.pdf', '2021-01-10', 'Cedida pelo Zoológico de São Paulo', 'Entrada', NULL, 'Zoológico de São Paulo'),
(3, 'Laudo de Nascimento', 'DOC-1122-B', 'laudo_nasc_dengo.pdf', '2021-03-15', 'Nascido em cativeiro autorizado', 'Entrada', NULL, 'Maternidade Veterinária BioParque');

-- Tabela: Triagem
INSERT INTO Triagem (Animal, Data, PesoAoChegar, ScoreCorporal, GravidadeVeterinária, Observações, IdadeNaTriagem) VALUES
(1, '2026-06-01', 85.4, 'Ideal', 'Normal', 'Avaliação periódica semestral', 6),
(3, '2026-06-02', 38.2, 'Abaixo do Peso', 'Alerta', 'Triagem realizada após relato de leve apatia alimentar', 5);

-- Tabela: RegistroRotina
INSERT INTO RegistroRotina (Animal, TipoRotina, DataHorario, Observações, DiasSemanal) VALUES
(1, 'Enriquecimento Ambiental', '2026-06-15 10:00:00', 'Interagiu com o estímulo por 25 minutos até acessar o alimento.', 'Segunda-feira'),
(3, 'Caminhada Monitorada', '2026-06-16 08:30:00', 'Apresentou bom ritmo e explorou ativamente os troncos caídos.', 'Terça-feira');

-- Tabela: Restrições
INSERT INTO Restricoes (Animal, Data, Restrição) VALUES
(1, '2026-06-01', 'Nenhuma restrição alimentar ou clínica de manejo identificada.'),
(3, '2026-06-02', 'Evitar oferta de itens rígidos por 48 horas devido a desgaste na dentição.');

-- Tabela: Risco
INSERT INTO Risco (Animal, Data, Risco) VALUES
(1, '2026-06-01', 'Baixo - animal habituado aos procedimentos sob contenção química.'),
(3, '2026-06-02', 'Médio - risco de ferimentos por garras durante a contenção física.');

-- Tabela: RegistroBiológico
INSERT INTO RegistroBiologico (Animal, DataTriagem, DataHoraRegistro, Ocorrência, Detalhamento, AnexoLaudoSaúde, Funcionário) VALUES
(1, '2026-06-01', '2026-06-01 11:00:00', 'Coleta de Sangue de Rotina', 'Coletado sangue da veia cefálica para hemograma completo.', 'laudo_hemograma_juma.pdf', '98765432100'),
(3, '2026-06-02', '2026-06-02 09:15:00', 'Coleta de Material Fecal', 'Análise parasitológica coprológica solicitada.', 'laudo_copro_dengo.pdf', '98765432100');

-- Tabela: RegistroClínico
INSERT INTO RegistroClinico (ID, Animal, DataTriagem, DataHoraRegistro, Ocorrência, Tratamento, Funcionário) VALUES
(101, 1, '2026-06-01', '2026-06-01 11:30:00', 'Vacinação Anual', 'Aplicação de reforço vacinal tríplice felina.', '12345678901'),
(102, 3, '2026-06-02', '2026-06-02 10:00:00', 'Tratamento de Endoparasitas', 'Administração de vermífugo oral de amplo espectro.', '12345678901');

-- Tabela: MedicamentoAdministrado
INSERT INTO MedicamentoAdministrado (ID, Medicamento, DosePV) VALUES
(101, 'Vacina Tríplice Felina Nobivac', '1.0 mL dose única SC'),
(102, 'Vermífugo Praziquantel/Pirantel', '1 comprimido para cada 10kg de PV');

-- Tabela: Exames
INSERT INTO Exames (ID, Data, Tipo, Resultado, Observação) VALUES
(101, '2026-06-01', 'Sorologia Preventiva', 'Negativo para FIV/FeLV', 'Procedimento preventivo padrão'),
(102, '2026-06-05', 'Coprológico de Controle', 'Ausência de ovos ou oocistos', 'Exame pós-tratamento realizado para certificar eficácia');