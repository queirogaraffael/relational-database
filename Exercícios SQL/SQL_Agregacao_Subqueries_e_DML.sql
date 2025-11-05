----- TABELA -----

EMPREGADO (matricula, nome, endereco, salario, supervisor, depto, sexo)
DEPARTAMENTO (coddep, nome (do depto), gerente, dataini)
PROJETO (codproj, nome (do proj), local, depart)
ALOCACAO (matric, codigop, horas)
DEPENDENTE (coddepend, mat, nome (do dependente), sexo)

----- 1. Consultas com Múltiplos JOINs e Agregação -----

Exercício 1.1: Média Salarial por Departamento Liste o nome de cada departamento e a 
média salarial dos empregados que trabalham nele. Ordene pelo nome do departamento.

SELECT d.nome, AVG(f.salario) AS media_salario_departamento
FROM departamento d
JOIN funcionario f ON d.coddep = f.dpto
GROUP BY d.nome, media_salario_departamento
ORDER BY d.nome

Exercício 1.2: Total de Horas Alocadas por Projeto Para cada projeto, mostre o nome do projeto e o total de 
horas alocadas por todos os empregados. Inclua apenas projetos que tenham mais de 10 horas alocadas no total.

SELECT p.nome, SUM(a.horas) AS soma_horas_alocadas_todos_funcionarios
FROM alocao a 
JOIN projeto p ON a.codigop = p.codproj
GROUP BY p.nome
HAVING SUM(a.horas) > 10;

Exercício 1.3: Empregados e Seus Supervisores Liste o nome de cada empregado, 
o nome do seu supervisor e o nome do departamento em que o empregado trabalha.

SELECT e.nome, s.nome, d.nome
FROM departamento d
JOIN empregado e ON d.coddep = e.depto
LEFT JOIN empregado s ON e.supervisor = s.matricula

Exercício 1.4: Projetos por Localização e Departamento Liste o nome do projeto,
o local do projeto e o nome do departamento responsável por ele. Ordene por local e depois por nome do projeto.

SELECT p.nome AS projeto_nome, p.local AS local_projeto, d.nome AS nome_departamento
FROM PROJETO p
JOIN DEPARTAMENTO d ON p.depart = d.coddep
ORDER BY p.local, p.nome

----- 2. Consultas com Subconsultas (Subqueries) -----

Exercício 2.1: Empregados com Salário Acima da Média Liste o nome e o salário de todos os 
empregados que ganham um salário superior à média salarial de todos os empregados da empresa.

SELECT nome, salario
FROM EMPREGADO
WHERE salario > (SELECT AVG(e.salario)
FROM EMPREGADO e)

Exercício 2.2: Gerentes Sem Dependentes Liste o nome dos empregados que são gerentes de algum 
departamento (coluna gerente da tabela DEPARTAMENTO) mas que não possuem dependentes.

SELECT e.nome 
FROM EMPREGADO e
JOIN DEPARTAMENTO depart ON e.matricula = depart.gerente
WHERE e.matricula NOT IN (SELECT d.mat 
							FROM DEPENDENTE d)
							
Exercício 2.3: Departamentos sem Empregados em Projetos de Campina Grande Liste o nome dos departamentos 
que não possuem nenhum empregado alocado em projetos localizados em 'Campina Grande'.

ALOCACAO, EMPREGADO, DEPARTAMENTO, PROJETO

SELECT DISTINCT d.nome
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
WHERE e.matricula NOT IN (SELECT a.matric
							FROM ALOCACAO a
							JOIN PROJETO p ON a.codigop = p.codproj
							WHERE p.local = 'Campina Grande')

----- 3. Consultas com Agregação e Condições (GROUP BY e HAVING) -----

Exercício 3.1: Departamentos com Mais de Um Projeto Liste o nome do departamento e a quantidade de projetos que ele
gerencia, mas inclua na lista apenas os departamentos que gerenciam mais de um projeto.

SELECT d.nome, COUNT(p.codproj) AS quantidade_projeto
FROM DEPARTAMENTO d
JOIN PROJETO p ON d.coddep = p.depart
GROUP BY d.nome 
HAVING COUNT(p.codproj) > 1;

Exercício 3.2: Dependentes por Empregado com Mais de Um Dependente Liste o nome do empregado e a quantidade de 
dependentes que ele possui, mas apenas para os empregados que têm 2 ou mais dependentes.

SELECT e.nome, COUNT(d.coddepend) AS quantidade_dependentes
FROM EMPREGADO e
JOIN DEPENDENTE d ON e.matricula = d.mat
GROUP BY e.nome
HAVING COUNT(d.coddepend) >= 2;

Exercício 3.3: Empregados Mais Alocados Liste o nome do empregado e o total de horas que ele está alocado em projetos, 
mas apenas para os empregados que estão alocados por mais de 10 horas no total.

SELECT e.nome, SUM(a.horas) AS total_horas_projetos
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
GROUP BY e.nome
HAVING SUM(a.horas) > 10;

----- EXISTS / NOT EXISTS -----
Exercício 4.1:  Recupere o nome de cada empregado que tem um dependente com o mesmo
nome e mesmo sexo

SELECT e.nome 
FROM EMPREGADO e
WHERE EXISTS (SELECT * 
				FROM DEPENDENTE d
				WHERE e.nome = d.nome AND e.sexo = d.sexo)

Exercício 4.2: Selecione o nome do empregado e o nome do departamento em que ele está lotado, de todos os
empregados que participam de projetos;

SELECT e.nome, d.nome
FROM EMPREGADO e
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE EXISTS (SELECT 1
			   FROM ALOCACAO a
			   WHERE e.matricula = a.matric)

Exercício 4.3: Retorne o nome e endereço dos empregados, além do nome dos departamentos nos quais eles
estão lotados, dos funcionários que não estão em nenhuma projeto do departamento de Sistemas;

SELECT e.nome, e.endereco, d.nome
FROM EMPREGADOS e
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE NOT EXISTS (SELECT 1 
					FROM ALOCACAO a
					JOIN PROJETO p ON a.codigoj = p.codproj
					WHERE e.matricula = a.matric AND p.depart = d.coddep AND d.nome = 'Sistemas' )

Exercício 4.4: Obtenha a matrícula e o nome de todos os empregados que têm filhos, mas que não estão em
nenhum projeto;

SELECT e.matricula, e.nome
FROM EMPREGADOS e
JOIN DEPENDENTE d ON e.matricula = d.mat
WHERE NOT EXISTS (SELECT 1 
				FROM ALOCACAO a
				JOIN PROJETO p ON a.codigop = p.codproj
				WHERE a.matric = e.matricula);

----- Conjuntos de Valores Explícitos -----

Exercício 5.1: Selecione o nome e o salário do funcionário, além do código do departamento de todos os funcionários
alocados nos projetos 10,11 ou 12;

SELECT f.nome, f.salario, d.coddep
FROM EMPREGADO f 
JOIN ALOCACAO a ON f.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
JOIN DEPARTAMENTO d ON p.depart = d.coddep
WHERE p.codproj IN (10,11,12);

----- IS NULL / IS NOT NULL

Exercício 6.1: Obtenha o nome do projeto e o código do departamento de todos os projetos que ainda não 
têm cidade de atuação;

SELECT p.nome, d.coddep
FROM PROJETO p
JOIN DEPARTAMENTO d ON p.depart = d.coddep
WHERE p.local IS NULL;

Exercício 6.2: Retorne o nome do empregado, a matrícula dele e o nome do departamento de todos os funcionários
que ainda não estão com endereço cadastrado;

SELECT e.nome, e.matricula, d.nome
FROM EMPREGADO e
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE e.endereco IS NULL;

Exercício 6.3: Selecione o nome e o salário de todos os empregados que estão em projetos já com localização
cadastrada, mas que ainda não estão com salário definido;

SELECT e.nome, e.salario
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
WHERE p.local IS NOT NULL AND e.salario IS NULL;

----- Contagem/ Totalização/ etc

Exercício 7.1: Mostre a média salarial, a soma salarial, o maior salário e o menor salário de todos os empregados
alocados no “Projeto X”, mostrando quantos funcionários estão alocados nele;

SELECT p.nome, COUNT(a.matric), AVG(e.salario), SUM(e.salario), MAX(e.salario), MIN(e.salario)
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
WHERE p.nome = 'Projeto X'
GROUP BY p.nome

----- GROUP BY

Exercício 8.1: Obtenha o código do departamento e a quantidade de projetos pertencentes a cada
departamento que tem projetos;

SELECT d.coddep, COUNT(DISTINCT a.codigop)
FROM ALOCACAO a
JOIN PROJETO p ON a.codigop = p.codproj
JOIN DEPARTAMENTO d ON p.depart = d.coddep
WHERE a.codigop IS NOT NULL
GROUP BY d.coddep;

Exercício 8.2: Para os empregados com projetos, retorne a matrícula do funcionário e o total de projetos dos
quais cada funcionário está participando;

SELECT f.matricula, COUNT(DISTINCT a.codigop)
FROM EMPREGADO f
JOIN ALOCACAO a ON f.matricula = a.matric
GROUP BY f.matricula;

Exercício 8.3: Para cada empregado do sexo masculino, obtenha o nome do empregado, a matrícula dele, e a
quantidade de dependentes que ele tem;

SELECT e.nome, e.matricula, COUNT(d.coddepend)
FROM EMPREGADO e
JOIN DEPENDENTE d ON e.matricula = d.mat
WHERE e.sexo = 'masculino'
GROUP BY e.nome, e.matricula;

Exercício 8.4: Mostre o nome do projeto, e a quantidade de pessoas alocadas em cada um desses projetos;

SELECT p.nome, COUNT(a.matric)
FROM PROJETO p
JOIN ALOCACAO a ON p.codproj = a.codigop
GROUP BY p.nome

Exercício 8.5: Para cada departamento, mostre o nome do departamento, os nomes de todos os empregados, e
mostre em quantos projetos cada empregado está alocado;

SELECT d.nome, e.nome, COUNT(a.matric)
FROM DEPARTAMENTO d 
JOIN EMPREGADO e ON d.coddep = e.depto
JOIN ALOCACAO a ON e.matricula = a.matric
GROUP BY d.nome, e.nome

Exercício 8.6: Mostre o nome e o código de todos os projetos, listando as matrículas de todas as pessoas alocadas
em cada um deles e informando quantos filhos cada pessoa tem;

SELECT p.nome, p.codproj, a.matric, COUNT(d.coddend)
FROM PROJETO p
JOIN ALOCACAO a ON p.codproj = a.codigop
LEFT JOIN DEPENDENTE d ON a.matric = d.mat
GROUP BY p.nome, p.codproj, a.matric;

Exercício 8.7: Para todos os departamentos, mostre o nome do departamento, e o nome das pessoas que ainda não
têm salário, mostrando em quantos projetos cada pessoa está, se a pessoa tiver filhos (usando EXISTS);

SELECT d.nome, e.nome, COUNT(a.codigop)
FROM DEPARTAMENTO d 
JOIN EMPREGADO e ON d.coddep = e.depto
LEFT JOIN ALOCACAO a ON e.matricula = a.mat
WHERE EXISTS (SELECT 1
				FROM DEPENDENTE depend
				WHERE e.matricula = depend.mat) AND e.salario IS NULL
GROUP BY d.nome, e.matricula, e.nome

Exercício 8.8: Para cada departamento, retorne o nome do departamento, mostre para cada empregado do
departamento, o nome do empregado e quantos dependentes cada um tem;


SELECT d.nome, e.nome, COUNT(depend.coddepend)
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
LEFT JOIN DEPENDENTE depend ON e.matricula = depend.mat
GROUP BY d.nome, e.matricula, e.nome;

Exercício 8.9: Para cada departamento, liste o nome do departamento, os nomes e matrículas dos
empregados e mostre em quantos projetos cada um deles está;

SELECT d.nome, e.nome, e.matricula, COUNT(a.codigop)
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
LEFT JOIN ALOCACAO a ON e.matricula = a.matric
GROUP BY d.nome, e.matricula, e.nome;

Exercício 8.10: Para cada departamento, obtenha o nome do departamento, a lista dos nomes dos empregados de
cada departamento, a lista dos códigos dos projetos em que cada empregado trabalha, e a quantidade de dependentes;

SELECT d.nome, e.nome, e.matricula, p.codproj, COUNT(depend.coddepend) AS total_dependentes
FROM departamento d 
JOIN projeto p ON d.coddep = p.depart 
JOIN alocacao a ON p.codproj = a.codproj
JOIN empregado e ON a.matric = e.matricula 
LEFT JOIN dependente depend ON e.matricula = depend.mat 
GROUP BY d.nome, e.matricula, e.nome, p.codproj
ORDER BY d.nome, e.nome;

Exercício 8.11: Para cada projeto que possui mais de 2 empregados trabalhando, obter o código do projeto,
nome do projeto e número de empregados que trabalham neste projeto

SELECT p.codproj, p.nome, COUNT(DISTINCT a.matric)
FROM PROJETO p
JOIN ALOCACAO a ON p.codproj = a.codigop
GROUP BY p.codproj, p.nome
HAVING COUNT(DISTINCT a.matric) > 2;

----- HAVING

Exercício 9.1: Retorne o código e o nome do departamento, e a quantidade de funcionários para aqueles
departamentos com menos de 10 empregados;

SELECT d.coddep, d.nome, COUNT(e.matricula)
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
GROUP BY d.coddep, d.nome
HAVING COUNT(e.matricula) < 10;

Exercício 9.2: Para cada departamento, obter o nome do departamento e os nomes dos empregados que têm
exatamente 2 filhos

SELECT d.nome, e.nome
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
JOIN DEPENDENTE depend ON e.matricula = depend.matric
GROUP BY d.nome, e.nome, e.matricula
HAVING COUNT(depend.coddepend) = 2;

Exercício 9.3: Por projeto, selecione o nome de todas as pessoas que têm mais de um filho e ainda estão sem endereço
definido;

SELECT p.nome, e.matricula, e.nome
FROM PROJETO p 
JOIN ALOCACAO a ON p.codproj = a.codproj
JOIN EMPREGADO e ON a.matric = e.matricula
JOIN DEPENDENTE depend ON e.matricula = depend.mat
WHERE e.endereco IS NULL
GROUP BY p.nome, e.matricula, e.nome
HAVING COUNT(depend.coddepend) > 1;

----- BETWEEN

Exercício 10.1: Retorne o nome, a matrícula e o salário de todos os empregados do sexo masculino que têm filhos, têm
salário entre R$2000.00 e R$5000.00 e possuem sobrenome “Fortune”;

SELECT e.nome, e.matricula, e.salario 
FROM EMPREGADO e
WHERE e.sexo = 'masculino' 
	AND e.salario BETWEEN 2000 AND 5000 
	AND e.nome LIKE '%Fortune'
	AND (SELECT COUNT(*) FROM DEPENDENTE d WHERE e.matricula = d.mat) > 0;
		
Exercício 10.2: Mostre quanto ficaria cada salário dos funcionários lotados no departamento de “Física’ e
que estão em algum projeto que tem nome começado por ‘Experimento’,

SELECT e.salario
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE d.nome = 'Física' 
	  AND p.nome LIKE 'Experimento%';

----- ORDENAÇÃO

Exercício 11.1: Para cada departamento, obter os empregados que recebem salário maior que 1500.00, mostrando o
nome do departamento, o nome do empregado e o salário, ordenando por nome do departamento e
nome do funcionário;

SELECT d.nome, e.nome, e.salario
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
WHERE e.salario > 1500
ORDER BY d.nome, e.nome

Exercício 11.2: Liste os nomes de todos os empregados e os nomes de todos os projetos nos quais eles estão
alocados, ordenando – por ordem alfabética – os nomes de funcionários e ordenando de Z para A os
nomes dos projetos;

SELECT e.nome, p.nome
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
ORDER BY e.nome ASC, p.nome DESC

Exercício 11.3: Para cada departamento, liste o nome do departamento, o código, o nome de cada um dos
empregados, o salário daqueles que recebem entre 1000.00 e 3000.00 (dando um aumento de 5%), e
que têm sobrenome “Silva” ou “Cavalcante”, mas apenas para aqueles empregados que têm mais de um
filho, ordenando pelo nome do departamento e pela matrícula do funcionário;

SELECT d.nome, d.coddep, e.nome, e.salario * 1.05
FROM DEPARTAMENTO d
JOIN EMPREGADO e ON d.coddep = e.depto
WHERE e.salario * 1.05 BETWEEN 1000 AND 3000
	AND (e.nome LIKE '%Silva' OR e.nome LIKE '%Cavalcante') AND (SELECT COUNT(*)
																	FROM DEPENDENTE depend
																	WHERE e.matricula = depend.mat) > 1
ORDER BY d.nome, e.matricula

Exercício 11.4: Para cada projeto, mostre o nome do projeto, a lista de empregado, mas apenas para os empregados com
mais de 3 dependentes, exibindo ordenado por nome do projeto (ascendente)

SELECT p.nome, e.nome
FROM PROJETO p
JOIN ALOCACAO a ON p.codproj = a.codigop
JOIN EMPREGADO e ON a.matric = e.matricula
WHERE (SELECT COUNT(*) FROM DEPENDENTE depend WHERE e.matricula = depend.mat) > 3
ORDER BY p.nome ASC

----- INSERÇÃO VIA SELECT

Exercício 12.1: Insira na tabela Dependente, uma tupla com os dados r(Dependente) = {3, 112233, “Joãozinho
Traquina”, M};

INSERT INTO DEPENDENTE (coddepend, mat, nome, sexo)
VALUES (3, 112233, 'Joãozinho Traquina', 'M');

Exercício 12.2: Crie a tabela SalarioDepart contendo o código do departamento, o nome do departamento e a soma dos
salários de todos os funcionários de cada departamento

CREATE TABLE SalarioDepart (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_departamento INT, 
    nome_departamento VARCHAR(100),
    soma_salarios DECIMAL(10, 2),
    
    FOREIGN KEY (id_departamento) REFERENCES Departamento(id_departamento)
);

INSERT INTO SalarioDepart (id_departamento, nome_departamento, soma_salarios)
SELECT
    D.codigo_departamento,
    D.nome_departamento,
    SUM(F.salario)
FROM
    Departamento D
JOIN
    Funcionario F ON D.codigo_departamento = F.codigo_departamento
GROUP BY
    D.codigo_departamento, D.nome_departamento;

----- DELEÇÃO DE DADOS

Exercício 13.1: Delete todos os funcionários do departamento de Biologia e depois delete o departamento de Biologia;

DELETE FROM FUNCIONARIO f
WHERE f.depto = (SELECT d.coddep
				FROM DEPARTAMENTO d
				WHERE d.nome = 'Biologia');

DELETE FROM DEPARTAMENTO
WHERE nome = 'Biologia';

----- ATUALIZAÇÃO DE DADOS

Exercício 14.1: Modifique para R$3000.00 o salário de todos os empregados

UPDATE EMPREGADO SET salario = 30000.00;