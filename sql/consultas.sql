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