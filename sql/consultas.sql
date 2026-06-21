/*
Consulta 1 - Espécies com animais em estado de alerta

Para cada espécie que possui plano de manejo (plano_de_manejo = 'S'), listar
o nome comum, a quantidade de animais triados com gravidade veterinária
diferente de 'Normal' e o peso médio desses animais, considerando apenas a
triagem mais recente de cada animal. Exibir somente espécies com 2 ou mais
animais em estado não-normal.
*/
-- seleciona a última triagem de cada animal
WITH UltimaTriagem AS (
    -- garante apenas a primeira linha de cada animal com base na ordenação
    SELECT DISTINCT ON (animal) 
        animal, 
        peso_ao_chegar, 
        gravidade_veterinaria
    FROM triagem
    ORDER BY animal, data_triagem DESC
)
SELECT 
    e.nome_comum AS especie,
    COUNT(*) AS animais_em_alerta,
    ROUND(AVG(ut.peso_ao_chegar), 2) AS peso_medio_kg
FROM especie e
    INNER JOIN animal a ON a.especie = e.nome_cientifico
    INNER JOIN UltimaTriagem ut ON ut.animal = a.nro_reg
WHERE 
    e.plano_de_manejo = 'S'
    AND ut.gravidade_veterinaria <> 'Normal'
GROUP BY e.nome_comum
HAVING COUNT(*) >= 2
ORDER BY animais_em_alerta DESC;

/*
Consulta 2 - Animais do plantel que nunca receberam tratamento clínico

Encontrar todos os animais que pertencem ao plantel (plantel = 'S') e que
nunca tiveram nenhum registro clínico associado, incluindo também seus dados
de alocação atual (recinto em que se encontram).
*/

SELECT
    a.nro_reg,
    a.apelido,
    e.nome_comum AS especie,
    r.nome AS recinto_atual,
    al.data_entrada AS entrada_no_recinto
FROM animal a
    INNER JOIN especie e ON e.nome_cientifico = a.especie
    -- Junção externa: traz animais MESMO SEM registros clínicos
    LEFT JOIN  registro_clinico rc ON rc.animal = a.nro_reg
    -- Alocação ativa (sem data de saída)
    INNER JOIN alocacao al ON al.animal  = a.nro_reg
                           AND al.data_saida IS NULL
    INNER JOIN recinto r ON r.recinto_gefau = al.recinto
WHERE
    a.plantel = 'S'
    AND rc.id IS NULL -- Filtra apenas quem NÃO tem registro
ORDER BY e.nome_comum, a.apelido;

/*
Consulta 3 - Ranking de funcionários por volume e diversidade de atendimentos

Para cada funcionário, calcular (a) quantos registros biológicos realizou,
(b) quantos registros clínicos realizou, (c) quantas espécies distintas
atendeu, e (d) a data do último atendimento. Classificar automaticamente
o funcionário como "Alta demanda", "Demanda moderada" ou "Baixa demanda" 
com base no total de registros.
*/

WITH todos_registros AS (
    -- Unifica registros biológicos e clínicos em uma única visão
    SELECT
        rb.funcionario,
        rb.animal,
        rb.data_hora_registro,
        'Biológico' AS tipo
    FROM registro_biologico rb

    UNION ALL

    SELECT
        rc.funcionario,
        rc.animal,
        rc.data_hora_registro,
        'Clínico' AS tipo
    FROM registro_clinico rc
)
SELECT
    f.nome AS funcionario,
    f.funcao,
    COUNT(*) FILTER (WHERE tr.tipo = 'Biológico') AS registros_biologicos,
    COUNT(*) FILTER (WHERE tr.tipo = 'Clínico') AS registros_clinicos,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT a.especie) AS especies_atendidas,
    MAX(tr.data_hora_registro)::DATE AS ultimo_atendimento,
    CASE
        WHEN COUNT(*) >= 50 THEN 'Alta demanda'
        WHEN COUNT(*) >= 10 THEN 'Demanda moderada'
        ELSE 'Baixa demanda'
    END                                                        AS classificacao
FROM funcionario f
    INNER JOIN todos_registros tr ON tr.funcionario = f.cpf
    INNER JOIN animal a ON a.nro_reg = tr.animal
GROUP BY f.cpf, f.nome, f.funcao
ORDER BY total_registros DESC;

/*
Consulta 4 - Divisão relacional: animais alocados em todos os recintos do parque

Encontrar os animais que já passaram por todos os recintos cadastrados no
sistema (operação de divisão relacional). Essa consulta responde à pergunta:
"Quais animais foram alocados em cada um dos recintos existentes?"
*/

-- "Não existe nenhum recinto para o qual NÃO exista uma alocação deste animal"
SELECT
    a.nro_reg,
    a.apelido,
    e.nome_comum AS especie
FROM animal a
    INNER JOIN especie e ON e.nome_cientifico = a.especie
WHERE NOT EXISTS (
    -- Para cada recinto do parque...
    SELECT 1
    FROM recinto r
    WHERE NOT EXISTS (
        -- ...verifica se o animal já esteve nele
        SELECT 1
        FROM alocacao al
        WHERE al.animal = a.nro_reg
          AND al.recinto = r.recinto_gefau
    )
)
ORDER BY a.apelido;

/*
Consulta 5 - Animais residentes a longo prazo por recinto e espécie

Para cada recinto e cada espécie atualmente alocada nele, calcula o número 
de indivíduos que estão residindo no local há mais de 1 ano. Caso uma espécie 
esteja presente no recinto, mas todos os seus indivíduos tenham chegado há 
menos de 1 ano, a contagem retornará 0 de forma explícita.
*/

SELECT 
    r.nome AS recinto,
    e.nome_comum AS especie,
    COUNT(*) FILTER (WHERE al.data_entrada <= CURRENT_DATE - INTERVAL '1 year') AS qtd_mais_de_1_ano
FROM alocacao al
    INNER JOIN animal a ON a.nro_reg = al.animal
    INNER JOIN especie e ON e.nome_cientifico = a.especie
    INNER JOIN recinto r ON r.recinto_gefau = al.recinto
WHERE 
    al.data_saida IS NULL -- Garante que estamos olhando apenas para quem ESTÁ no recinto hoje
GROUP BY 
    r.nome, 
    e.nome_comum
ORDER BY 
    r.nome, 
    e.nome_comum;

/*
Listar todos os recintos pelos quais um animal passou, 
com datas de entrada e saída, ordenado cronologicamente.
*/
SELECT Recinto, DataDeEntrada, DataDeSaida
FROM ALOCACAO
WHERE NroReg = 123456789
ORDER BY DataDeEntrada ASC;

/*
Calcular a quantidade total de cada medicamento administrado
em um intervalo de datas, agrupados por medicamento.
*/
SELECT MA.Medicamento, SUM(MA.DosePV) AS "TotalAdministrado"
FROM REGISTROCLINICO RC
JOIN MEDICAMENTOADMINISTRADO MA
    ON RC.ID = MA.ID
WHERE RC.DataHoraRegistro BETWEEN TO_DATE('01/01/2026', 'DD/MM/YYYY') 
                              AND TO_DATE('31/01/2026', 'DD/MM/YYYY')
GROUP BY MA.Medicamento;

/*
Listar todos os funcionários, incluindos aqueles sem nenhum registro 
realizado no período(último mês), com a contagem de registros de cada um.
*/
SELECT F.CPF, COUNT(R.Funcionario) AS "Total_Registros"
FROM FUNCIONARIO F 
LEFT JOIN (
    -- Reúne todos os registros biológicos do último mês
    SELECT Funcionario 
    FROM REGISTROBIOLOGICO 
    WHERE DataHoraRegistro >= SYSDATE - 30
    
    -- Empilha a coluna de cima com a debaixo
    UNION ALL
    
    -- Reúne todos os registros clínicos do último mês
    SELECT Funcionario 
    FROM REGISTROCLINICO 
    WHERE DataHoraRegistro >= SYSDATE - 30
) R ON F.CPF = R.Funcionario
GROUP BY F.CPF;

/*
Listar todas as triagens de um animal ordenadas por data,
exibindo peso e score corporal em cada uma, permitindo
acompanhar a evolução clínica ao longo do tempo.
*/
-- Devo retornar o animal e a Data?
SELECT Animal, DataTriagem, PesoAoChegar AS "PESO", ScoreCorporal
FROM TRIAGEM T
WHERE Animal = 123456789
ORDER BY DataTriagem ASC;

/*
Listar recintos cuja ocupação atual supera um percentual 
definido da capacidade máxima, ordenados pelo percentual 
de ocupação de forma descrescente. Supoe-se como 90%.
*/
SELECT RecintoGEFAU, (QntAnimais*1.0/CapMaxima) AS "Percentual Ocupação"
FROM RECINTO
WHERE (QntAnimais*1.0/CapMaxima) >= 0.9 
ORDER BY "Percentual Ocupação" DESC;

/*
Identificar casais ativos cuja prole ainda não foi 
cadastrada no sistema, útil para monitoramento.
-- Consulta correlacionada
*/
SELECT C.Animal1 AS "PAI", C.Animal2 AS "MAE"
FROM CASAL C
WHERE NOT EXISTS (
    SELECT 1 
    FROM PROLE P
    WHERE P.Pai = C.Animal1 
      AND P.Mae = C.Animal2
);

/*
Listar espécies cujos animais estão distribuídos em recintos diferentes,
com a quantidade de recintos ocupados por cada espécie.

-- Sem Sub consulta
SELECT ANIM.Especie, 
    COUNT(DISTINCT ALOC.Recinto) AS "Qtd_Recintos"
FROM ANIMAL ANIM 
JOIN ALOCACAO ALOC 
    ON ANIM.NroReg = ALOC.Animal
WHERE ALOC.DataDeSaida IS NULL
GROUP BY ANIM.Especie
    HAVING COUNT(DISTINCT ALOC.Recinto) > 1;
*/
SELECT EspeciePorRecinto.Especie, COUNT(*) AS "Qtd_Recintos"
FROM (
    SELECT ANIM.Especie, ALOC.Recinto
    FROM ANIMAL ANIM
    JOIN ALOCACAO ALOC 
        ON ANIM.NroReg = ALOC.Animal
    WHERE ALOC.DataDeSaida IS NULL
    GROUP BY ANIM.Especie, ALOC.Recinto
) EspeciePorRecinto
GROUP BY EspeciePorRecinto.Especie
    HAVING COUNT(*) > 1;