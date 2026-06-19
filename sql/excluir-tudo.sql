-- 1. Tabelas folha (nenhuma outra tabela depende delas)
DROP TABLE IF EXISTS prole                  CASCADE;
DROP TABLE IF EXISTS exames                 CASCADE;
DROP TABLE IF EXISTS medicamento_administrado CASCADE;
DROP TABLE IF EXISTS restricoes             CASCADE;
DROP TABLE IF EXISTS risco                  CASCADE;
DROP TABLE IF EXISTS registro_biologico     CASCADE;
DROP TABLE IF EXISTS registro_rotina        CASCADE;
DROP TABLE IF EXISTS item_cardapio          CASCADE;
DROP TABLE IF EXISTS documento              CASCADE;
DROP TABLE IF EXISTS alocacao               CASCADE;

-- 2. Tabelas intermediárias (dependem das raízes, mas são pai das folhas)
DROP TABLE IF EXISTS casal                  CASCADE;
DROP TABLE IF EXISTS registro_clinico       CASCADE;
DROP TABLE IF EXISTS descricao_rotina       CASCADE;
DROP TABLE IF EXISTS triagem                CASCADE;

-- 3. Tabelas raízes (sem dependências externas)
DROP TABLE IF EXISTS animal                 CASCADE;
DROP TABLE IF EXISTS especie                CASCADE;
DROP TABLE IF EXISTS recinto                CASCADE;
DROP TABLE IF EXISTS funcionario            CASCADE;