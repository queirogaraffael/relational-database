----- TABELA -----

EMPREGADO (matricula, nome, endereco, salario, supervisor, depto, sexo)
DEPARTAMENTO (coddep, nome (do depto), gerente, dataini)
PROJETO (codproj, nome (do proj), local, depart)
ALOCACAO (matric, codigop, horas)
DEPENDENTE (coddepend, mat, nome (do dependente), sexo, parentesco)



SELECT e.matricula, e.nome, SUM(a.horas)
FROM EMPREGADO e 
JOIN ALOCACAO a ON e.matricula = a.matric
WHERE e.matricula = 12345
GROUP BY e.matricula, e.nome;



----- Exercicios de Transações e Stored Procedures -----

01) Escreva a transação explícita que insere o empregado {12345, "Eliclediúscio", "Rua das Laranjas", 2000.00, 67890, 4, 'M'}, 
depois altera o salário dele diminuindo em 5%, e por fim deleta o departamento 12. Depois de tudo isso, todo o processamento deve ser desfeito;

BEGIN TRANSACTION;

INSERT INTO Empregado (matricula, nome, endereco, salario, chefe, departamento, sexo)
VALUES (12345, 'Eliclediusco', 'Rua das Laranjas', 2000.00, 67890, 4, 'M');

UPDATE Empregado
SET salario = salario * 0.95
WHERE matricula = 12345;

DELETE FROM Departamento
WHERE codigo = 12;

ROLLBACK;

02) Escreva a transação explícita que adiciona um dependente com os dados {3, 234, "Pleuriskelly", 'F'}. 
Em seguida exibe uma tabela com todos os dependentes desse empregado de matrícula 234, dá um aumento de 3% para ele, 
e persiste os dados adicionados na base de dados;

BEGIN TRANSACTION;

INSERT INTO DEPENDENTE(coddepend, mat, nome, sexo)
VALUES (3, 234, 'Pleuriskelly', 'F')

SELECT *
FROM DEPENDENTE d 
WHERE mat = 234;

UPDATE EMPREGADO SET salario = salario * 1.03 WHERE matricula = 234;

COMMIT;

03) Crie a stored procedure que recebe como parâmetro o nome de um departamento, e aumenta em 10% o 
salário dos empregados desse departamento, sendo que se a soma dos novos salários for maior que R$20.000,00, 
então o processo deve ser abortado e o BD deve manter os salários originais. Se a atualização não for feita, 
o usuário deve ser informado disso, e se for feita, a soma dos salários deve ser retornada;

CREATE OR REPLACE PROCEDURE aumentar_salario_departamento(IN nome_departamento TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    id_departamento INT;
    soma_salarial DECIMAL(10,2);
BEGIN

    SELECT coddep INTO id_departamento FROM DEPARTAMENTO WHERE nome = nome_departamento;

    UPDATE EMPREGADO SET salario = salario * 1.1 WHERE depto = id_departamento;

    SELECT SUM(salario) INTO soma_salarial FROM EMPREGADO WHERE depto = id_departamento;

    IF soma_salarial > 20000.00 THEN
        RAISE EXCEPTION 'Soma salarial de departamento maior do que 20 mil reais. Operação cancelada';
    ELSE 
        RAISE NOTICE 'Operação realizada com sucesso. Soma salarial %', soma_salarial;
    END IF;
END;
$$;

CALL aumentar_salario_departamento('Pesquisa');

04) Considere que os projetos têm o campo orçamento. Crie a SP que reduz o orçamento dos projetos de Psicologia em 2%, 
e em seguida testa se o novo valor é inferior a 20.000,00. Caso seja, todas as operações devem ser desfeitas e o 
cancelamento printado para o usuário. Caso o valor não seja inferior à meta estabelecida, então a operação é confirmada e informada ao usuário;

CREATE OR REPLACE PROCEDURE reduzir_orcamento_psicologia()
LANGUAGE plpgsql
AS $$
DECLARE
	id_departamento_psicologia INT;
	algum_invalido BOOLEAN;
BEGIN
	SELECT coddep INTO id_departamento_psicologia FROM DEPARTAMENTO WHERE nome = 'Psicologia';

	UPDATE Projeto
	SET orcamento = orcamento * 0.98
	WHERE depart = id_departamento_psicologia;

	SELECT EXISTS (SELECT 1 FROM Projeto WHERE depart = id_departamento_psicologia AND orcamento < 20000.00)
	INTO algum_invalido;

	IF algum_invalido THEN
		RAISE EXCEPTION 'Operação cancelada: Pelo menos um projeto de Psicologia teria um orçamento inferior a R$20.000,00.';
	ELSE
		RAISE NOTICE 'Operação confirmada: Orçamentos reduzidos e persistidos.';
	END IF;
END;
$$;

05) Escreva a SP que recebe os nomes de dois departamentos e descobre quantos funcionários existem em cada um. Se a soma dos dois departamentos 
for inferior ou igual a 50 pessoas, então um aumento de 5% é dado nos salários desses funcionários destes setores, caso seja superior a 50, 
a operação é desfeita e informada ao usuário. Depois de aplicar o aumento se a soma dos salários for superior a 100.000,00, então toda a 
operação é cancelada, e o cancelamento é informado ao usuário. Caso não ultrapasse, então todas as operações são confirmadas na base de dados;

CREATE OR REPLACE PROCEDURE nome_st(IN nome_departamento_um VARCHAR, IN nome_departamento_dois VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE
    id_departamento_um INT;
    id_departamento_dois INT;
    qtd_departamento_um INT;
    qtd_departamento_dois INT;
    soma_salario_departamentos DECIMAL(10,2);
    soma INT;
BEGIN

    SELECT coddep 
    INTO id_departamento_um 
    FROM DEPARTAMENTO 
    WHERE nome = nome_departamento_um;

    SELECT coddep 
    INTO id_departamento_dois 
    FROM DEPARTAMENTO 
    WHERE nome = nome_departamento_dois;

    SELECT COUNT(matricula) 
    INTO qtd_departamento_um 
    FROM EMPREGADO 
    WHERE depto = id_departamento_um;

    SELECT COUNT(matricula) 
    INTO qtd_departamento_dois 
    FROM EMPREGADO 
    WHERE depto = id_departamento_dois;

    soma := qtd_departamento_um + qtd_departamento_dois;

    IF soma <= 50 THEN

        UPDATE EMPREGADO 
        SET salario = salario * 1.05 
        WHERE depto IN (id_departamento_um, id_departamento_dois);

        SELECT SUM(salario) 
        INTO soma_salario_departamentos 
        FROM EMPREGADO 
        WHERE depto IN (id_departamento_um, id_departamento_dois);

        IF soma_salario_departamentos > 100000 THEN
            RAISE EXCEPTION 'Valor superior a 100.000 reais';
        END IF;

        RAISE NOTICE 'Aumento aplicado';
    ELSE
        RAISE EXCEPTION 'Operação cancelada';
    END IF;
END;
$$;

06) Escreva a SP que recebe as matrículas dos três empregados que possuem as maiores quantidades de dependentes do sistema. 
Deve ser dado um aumento no salário de 1% para cada dependente que eles possuem. Depois de dados os aumentos, 
é preciso somar os salários dos três, e caso o valor alcance ou ultrapasse 10.000,00, é preciso cancelar todas as 
alterações feitas e informar ao usuário do cancelamento. Caso o valor não seja alcançado, é preciso informar do 
aumento dado via texto e confirmar as ações;

CREATE OR REPLACE PROCEDURE aumento_salarial_top_dependentes()
LANGUAGE plpgsql
AS $$
DECLARE
	v_soma_salarios NUMERIC(10, 2);
BEGIN

	CREATE TEMPORARY TABLE temp_top3_empregados AS
	SELECT
		E.matricula,
		COUNT(D.mat) AS num_dependentes
	FROM Empregado E
	LEFT JOIN Dependente D ON E.matricula = D.mat
	GROUP BY E.matricula
	ORDER BY num_dependentes DESC
	LIMIT 3;

	UPDATE Empregado E
	SET salario = E.salario * (1 + (T.num_dependentes * 0.01))
	FROM temp_top3_empregados T
	WHERE E.matricula = T.matricula;

	SELECT SUM(E.salario) INTO v_soma_salarios
	FROM Empregado E
	JOIN temp_top3_empregados T ON E.matricula = T.matricula;

	IF v_soma_salarios >= 10000.00 THEN
		RAISE NOTICE 'Operação cancelada: A soma dos novos salários (R$%) atingiu ou ultrapassou R$10.000,00.', v_soma_salarios;
	ELSE
		RAISE NOTICE 'Aumentos confirmados. A nova soma dos salários é R$%. (Aumento de 1%% por dependente.)', v_soma_salarios;
	END IF;

	DROP TABLE temp_top3_empregados;
END;
$$;

07) Escreva a transação explícita que modifica para 'Campina Grande' todos os projetos que estão lotados em João Pessoa, 
são do departamento de Física, cujos empregados que nela trabalham possuem pai ou mãe como dependentes e que recebem salário 
entre R$2000,00 e 5000,00, exceto os projetos com nomes começados por 'Desenvolvimento'. Em seguida a transação deleta 
todos os empregados alocados em projetos de antropologia. Por fim, ela mostra na tela, por empregado, o nome do empregado, 
a sua matrícula e a quantidade de projetos em que estão alocados, e depois cancela todas essas ações;

BEGIN TRANSACTION;

UPDATE PROJETO 
SET local = 'Campina Grande'
WHERE local = 'João Pessoa'
    AND nome NOT LIKE 'Desenvolvimento%'
    AND depart IN (SELECT coddep FROM DEPARTAMENTO WHERE nome = 'fisica')
    AND codproj IN (
    
    SELECT a.codigop 
    FROM ALOCACAO a 
    JOIN EMPREGADO e ON a.matric = e.matricula
    JOIN DEPENDENTE d ON e.matricula = d.mat 
    WHERE d.parentesco IN('mãe', 'pai')
        AND e.salario BETWEEN 2000 AND 5000);

DELETE FROM EMPREGADO 
WHERE matricula IN (SELECT a.matric 
                    FROM ALOCACAO a 
                    JOIN PROJETO p ON a.codigop = p.codproj 
                    JOIN DEPARTAMENTO d ON p.depart = d.coddep
                    WHERE d.nome = 'antropologia');

SELECT e.nome, e.matricula, COUNT(a.codigop)
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
GROUP BY e.nome, e.matricula;

ROLLBACK;