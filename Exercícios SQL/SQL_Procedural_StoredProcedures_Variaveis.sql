----- Tabela -----

SerHumano(Matricula, Nome, Endereço)
Curso(Id, NomeCurso, DuracaoPeriodos)
Professor(MatProf, Titulacao, DtAdm, Salario, CursoId)
MatProf referencia SerHumano
CursoId referencia Curso
Aluno(MatAlu, PeriodoEntrada, Cidade, UF, IdCurso)
MatAlu referencia SerHumano
IdCurso referencia Curso
Disciplina(Codigo, NomeDisc, Creditos)
Ensina(ProfMat, DisCod, Periodo)
ProfMat referencia Professor
DisCod referencia Disciplina
Matriculado(AluMat, CodDisc, PeriodoMatricula, Unidade1, Unidade2, Unidade3, Final,
Media)
AluMat referencia Aluno
CodDisc referencia Disciplina
Recados(Numero, Msg)

PRINT(‘A soma dos salários do departamento’ + NomeDep+ ‘ é: ‘ + SomaSal)

DECLARE @indice INT;
SET @indice = SELECT COUNT(f.indice) + 1 FROM RECADOS f;

INSERT INTO Recados (Numero, Msg) VALUES (@indice, ‘Mensagem de teste’);

DO $$
DECLARE
  indice INT;
BEGIN
  SELECT COUNT(*) + 1 INTO indice FROM Recados;
  INSERT INTO Recados (Numero, Msg) VALUES (indice, 'Mensagem de teste');
END $$;


----- Exercicios -----

01) Descubra quantas disciplinas o professor Helidanicléblio já ministrou em toda a
sua carreira, e quantas ele está ministrando no período atual. Imprima na tela a
mensagem informando quantas disciplinas Helidaniclébio ministra no período
atual e quantas ele já ministrou na vida (Considere que só existe uma pessoa
com nome Helidanicléblio na base de dados e esse já é o nome completo
dele);

DECLARE @somaDisciplinasJaMinistradas;

SET @somaDisciplinasJaMinistradas = SELECT COUNT(e.DiscCod)
FROM SERHUMANO sh 
JOIN PROFESSOR p ON sh.Matricula = p.MatProf
JOIN ENSINA e ON p.MatProf = e.ProfMat
WHERE sh.Nome = 'Helidanicléblio' AND e.Periodo = 'anterior'

DECLARE @somaDisciplinasMinistradasAtualmente;

SET @somaDisciplinasMinistradasAtualmente = SELECT 	COUNT(e.DiscCod)
FROM SERHUMANO sh 
JOIN PROFESSOR p ON sh.Matricula = p.MatProf
JOIN ENSINA e ON p.MatProf = e.ProfMat
WHERE sh.Nome = 'Helidanicléblio' AND e.Periodo = 'atual'

PRINT(‘Soma disciplinas ja ministradas’ + somaDisciplinasJaMinistradas)
PRINT(‘Soma disciplinas ministradas atualmente’ + somaDisciplinasMinistradasAtualmente)

02) Calcule quantos professores pertencem ao curso de Sistemas de informação.
Depois descubra quanto alunos pertencem ao mesmo curso. Caso todos os
alunos fossem fazer TCC ao mesmo tempo, imprima na tela uma mensagem
informando a média de alunos que cada professor teria de orientar;


DECLARE @quantidadeProfessoresCursoSistemas INT;
DECLARE @quantidadeAlunoSistemas INT;
DECLARE @media NUMERIC;

SET @quantidadeProfessoresCursoSistemas = SELECT COUNT(p.MatProf) FROM PROFESSOR p
											JOIN Curso s ON p.CursoId = c.id
											WHERE s.NomeCurso = 'sistemas';
							
SET @quantidadeAlunoSistemas = SELECT COUNT(a.MatAlun) FROM ALUNO a
											JOIN Curso c ON a.CursoId = c.id
											WHERE s.NomeCurso = 'sistemas';

SET @media =  @quantidadeAlunoSistemas / @quantidadeProfessoresCursoSistemas;

PRINT('Media ' + @media)

03) Descubra a média geral das unidades de todos os alunos do curso de Direito,
para tanto calcule a média geral de cada uma das unidades (Unidade1,
Unidade2, Unidade3), depois some-as e divida-as por 3, informando o total
obtido numa mensagem na tela. Se a média for 9.0 ou superior, então imprima
que o curso tem média excelente. Se estiver entre 8.9 e 7.0, imprima que o
curso tem alunos com notas na média. Caso seja inferior a isso, imprima que o
curso está com uma média baixa;

DECLARE @mediaUnidade1 NUMERIC(3,1);
DECLARE @mediaUnidade2 NUMERIC(3,1);
DECLARE @mediaUnidade3 NUMERIC(3,1);
DECLARE @media NUMERIC(3,1);

SET @mediaUnidade1 = SELECT AVG(m.Unidade1)
FROM ALUNO a
JOIN CURSO c ON a.IdCurso = c.Id
JOIN MATRICULADO m ON a.MatAlu = m.AluMat
WHERE c.NomeCurso = 'direito'

SET @mediaUnidade2 = SELECT AVG(m.Unidade2)
FROM ALUNO a
JOIN CURSO c ON a.IdCurso = c.Id
JOIN MATRICULADO m ON a.MatAlu = m.AluMat
WHERE c.NomeCurso = 'direito'

SET @mediaUnidade3 = SELECT AVG(m.Unidade3)
FROM ALUNO a
JOIN CURSO c ON a.IdCurso = c.Id
JOIN MATRICULADO m ON a.MatAlu = m.AluMat
WHERE c.NomeCurso = 'direito'

SET @media = (@mediaUnidade1 + @mediaUnidade2 + @mediaUnidade3) / 3;

IF @media >= 9.0
    PRINT 'media excelente';
ELSE IF @media >= 7.0
    PRINT 'Curso com notas medias';
ELSE
    PRINT 'Curso abaixo da media';

04) Escreva a Stored Procedure (SP) que mostra por professor o nome do professor, 
a matrícula dele e quantas disciplinas ele ministra;

CREATE PROCEDURE informacoes_professores()
	BEGIN
		SELECT sh.Nome, sh.matricula, COUNT(d.Codigo)
		FROM Professor p
		JOIN SERHUMANO sh ON p.MatProf = sh.Matricula
		JOIN ENSINA e ON p.MatProf = e.ProfMat
		JOIN DISCIPLINA d ON e.DisCod = d.Codigo
		WHERE e.periodo = 'atual'
		GROUP BY sh.Nome, sh.matricula
	END;

CALL informacoes_professores();

05) Escreva a SP que recebe o nome de um curso e calcula a média salarial dos professores deste curso. 
Se a média for maior do que R$3000.00, deve ser incluído na tabela Recados um recado informando 
“Média salarial excelente”,se a média for menor do que R$3000.00, deve ser incluído um recado informando 
“Média salarial baixa”, e caso seja exatamente 3000, incluir o recado “Média salarial boa”; 

(incluir sempre na tabela Recados)

CREATE PROCEDURE mediaSalarialProfessorDoCurso (nomeCurso TEXT)
	DECLARE 
		media_salarial NUMERIC;
		indice INT;
	BEGIN
		SELECT AVG(.Salario) INTO media_salarial FROM PROFESSOR p JOIN CURSO c ON p.CursoId = c.Id WHERE c.NomeCurso = nomeCurso	

		SELECT COUNT(*) + 1 INTO indice FROM Recados;
		
		if media_salarial > 3000:
			INSERT INTO Recados (Numero, Msg) VALUES (indice, 'Média salarial excelente');
		else if media_salarial < 3000:
			INSERT INTO Recados (Numero, Msg) VALUES (indice, 'Média salarial baixa”,');
		else:
			INSERT INTO Recados (Numero, Msg) VALUES (indice, 'Média salarial boa');
		END IF;

	END;

CALL mediaSalarialProfessorDoCurso('sistemas');

06) Escreva a SP que recebe uma matrícula e descobre se a pessoa é uma professor ou se é um aluno. 
Se for professor, a SP conta quantas disciplinas ele já ministrou. Se for, aluno, a SP calcula 
em quantas disciplinas ele já se matriculou. A SP salva na tabela Recados um tupla informando o nome da
pessoa, se ele é professor ou aluno e informando a quantidade de disciplinas em que ele já se matriculou 
(se for aluno) ou que ele já ministrou (se for professor);

CREATE PROCEDURE aluno_professor(matricula INT)
	DECLARE
		eh_professor BOOLEAN;
		quantidade INT;
		indice INT;
		nome TEXT;
	BEGIN
		INSERT (COUNT(*) + 1) INTO indice FROM RECADOS r; 

		SELECT EXISTS (
		    SELECT 1
		    FROM PROFESSOR p
		    WHERE p.Matricula = matricula
		) AS eh_professor;

		SELECT sh.Nome INTO nome FROM SERHUMANO sh WHERE sh.Matricula = matricula;

		IF eh_professor:
			SELECT COUNT(d.Codigo) INTO quantidade
			FROM DISCIPLINA d
			JOIN ENSINA e ON d.Codigo = e.DisCod 
			WHERE e.ProfMat = matricula AND e.periodo = 'anterior';
			INSERT INTO Recados(Numero, Msg) VALUES(indice, 'Nome: ' + nome + ', é professor. Quantidade disciplinas ensinadas
			 = ' + quantidade);
			 
		ELSE:
			SELECT COUNT(d.Codigo) INTO quantidade
			FROM MATRICULADO m
			JOIN DISCIPLINA d ON m.CodDisc = d.Codigo;

			INSERT INTO Recados(Numero, Msg) VALUES(indice, 'Nome: ' + nome + ', é aluno. Quantidade disciplinas matriculadas
			= ' + quantidade);		
		END IF;
	
	END;

----- Variáveis em SQL -----

----- TABELA -----

EMPREGADO (matricula, nome, endereco, salario, supervisor, depto, sexo)
DEPARTAMENTO (coddep, nome (do depto), gerente, dataini)
PROJETO (codproj, nome (do proj), local, depart)
ALOCACAO (matric, codigop, horas)
DEPENDENTE (coddepend, mat, nome (do dependente), sexo)

07) Salve em uma variável a soma dos salários dos empregados do departamento de Sistemas que estão
em projetos com mais de 4 horas de carga horária, somado ao valor da média salarial dos empregados
do departamento de Antropologia que têm filhos do sexo masculino;

DECLARE somaSalarioSistemas INT;
DECLARE mediaSalarialAntropologiaFilhos NUMERIC(3,1);
DECLARE soma_mais_media NUMERIC(3,1);

SELECT SUM(e.salario)
INTO somaSalarioSistemas
FROM EMPREGADO e
JOIN DEPARTAMENTO d ON e.depto = d.coddep
JOIN ALOCACAO a ON e.matricula = a.matric
GROUP BY e.matricula
WHERE d.nome = 'sistemas' AND a.horas > 4;

SELECT AVG(e.salario)
INTO mediaSalarialAntropologiaFilhos
FROM EMPREGADO e
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE EXISTS (SELECT 1 FROM DEPENDENTE d WHERE d.sexo = 'masculino' AND d.mat = e.matricula)
	AND d.nome = 'antropologia';

SET soma_mais_media = somaSalarioSistemas + mediaSalarialAntropologiaFilhos;

08) Salve a maior carga horária dentre os empregados que trabalham no projeto “Informática
para Todos”, e que não sejam do departamento de Sistemas. Depois salve a menor carga horária dentre
os empregados de Sistemas que trabalham no mesmo projeto. Guarde em uma variável a média
dentre os dois valores salvos;

DECLARE maiorCargaHoraria INT;
DECLARE menorCargaHoraria INT;
DECLARE media NUMERIC(3,1);

SELECT MAX(a.horas)
INTO maiorCargaHoraria
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE p.nome = 'Informática para Todos'
		AND d.nome != 'sistemas';

SELECT MIN(a.horas)
INTO menorCargaHoraria
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
JOIN PROJETO p ON a.codigop = p.codproj
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE p.nome = 'Informática para Todos'
	AND d.nome = 'sistemas';

SET media = (maiorCargaHoraria + menorCargaHoraria) / 2 ;

----- Exibindo textos ----- 

09) Descubra a matrícula do empregado de nome Eubiglenivaldo do departamento de Fisioterapia e salve
numa variável. Com esse dado salvo, descubra quantos filhos esse funcionário tem e imprima a mensagem
informando o nome completo dele e a quantidade de filhos que ele tem (considere que há mais de 1
Eubiglenivaldo, mas só 1 de Fisioterapia);

DECLARE nome TEXT = 'Eubiglenivaldo';
DECLARE matricula INT;
DECLARE quantidadeFilhos INT;

SELECT e.matricula 
INTO matricula
FROM EMPREGADO e
JOIN DEPARTAMENTO d ON e.depto = d.coddep
WHERE d.nome = 'fisioterapia' 
	AND e.nome = 'Eubiglenivaldo';

SELECT COUNT(depend.coddepend)
INTO quantidadeFilhos
FROM DEPENDENTE d
WHERE d.mat = matricula;

PRINT('Nome: ' || nome || ' quantidade filhos: ' || quantidadeFilhos);

10) Descubra o empregado que é o gerente do departamento de sistemas. Depois descubra qual o salário
dele, conceda um aumento de 10% no valor do salário e em seguida imprima o nome do funcionário e o valor do
novo salário dele;

DECLARE idGerenteSistemas INT;
DECLARE salarioGerenteSistemas NUMERIC(10,2);
DECLARE nome TEXT;
DECLARE salarioComAumento NUMERIC(10,2);

SELECT mdepart.gerente
INTO idGerenteSistemas
FROM DEPARTAMENTO depart
WHERE depart.nome = 'sistemas';

SELECT e.nome, e.salario
INTO nome, salarioGerenteSistemas
FROM EMPREGADO e
WHERE e.matricula = idGerenteSistemas;

SET salarioComAumento = salarioGerenteSistemas * 1.10;

UPDATE EMPREGADO e SET e.salario = salarioComAumento WHERE e.matricula = idGerenteSistemas;

PRINT('Nome: ' || nome || 'Novo salario: ' || salarioComAumento)

----- Programando em SQL (IF) -----

11) Crie o código SQL que descobre o departamento em que o funcionário “Zenieldilênio” trabalha, conta a
média salarial e o total de funcionários deste setor. É preciso mostrar a média dos salários, e depois, caso
haja menos de 10 funcionários, imprimir “Muito dinheiro pra pouca gente”. Mas se forem mais de 10,
imprimir “Muita gente pra pouco dinheiro”. Se forem exatamente 10 pessoas, imprima “Dinheiro na medida certa”;

DECLARE idDepartamentoFuncionario INT;
DECLARE mediaSalarialSetor NUMERIC(10,2);
DECLARE totalFuncionariosSetor INT;

SELECT e.depto
INTO idDepartamentoFuncionario
FROM EMPREGADO e
WHERE e.nome = 'Zenieldilênio';

SELECT AVG(e.salario), COUNT(e.matricula)
INTO mediaSalarialSetor, totalFuncionariosSetor
FROM EMPREGADO e
WHERE e.depto = idDepartamentoFuncionario;

PRINT('Media salarial do setor: ' || mediaSalarialSetor);

if totalFuncionariosSetor > 10:
	PRINT('Muita gente pra pouco dinheiro')
ELSE IF totalFuncionariosSetor < 10:
	PRINT('Muito dinheiro pra pouca gente')
ELSE:
	PRINT('Dinheiro na medida certa')

----- Store procedure -----

12) Crie uma SP que mostre a soma dos salários dos empregados de uma empresa, separando por
departamento, citando o código do departamento, o nome do departamento e a soma dos salários;


CREATE PROCEDURE informacoes_empregados()
	BEGIN

	SELECT d.coddep, d.nome, SUM(e.salario)
	FROM DEPARTAMENTO d
	JOIN EMPREGADO e ON d.coddep = e.depto
	GROUP BY d.nome, d.coddep;
	
	END

13) Crie uma SP que retorna a soma dos salários de todas as mulheres de uma empresa;

CREATE PROCEDURE salarioMulheres(OUT salario_total_mulheres NUMERIC(10,2))
	BEGIN
		SELECT SUM(e.salario)
		INTO salario_total_mulheres
		FROM EMPREGADO e
		WHERE e.sexo = 'feminino';

	END

14) Crie uma SP que receba o código de um departamento e retorne a quantidade de funcionários
lotados nele e a soma dos salários dos funcionários, sabendo que a empresa possui 4 departamentos (1,
2, 3 e 4), e sabendo que é preciso informar quando o usuário fornece um código de departamento
inexistente;

CREATE PROCEDURE retorna_quantidade_funcionarios_departamento(IN idDepartamento INT, OUT total_funcionarios INT, OUT total_salarios NUMERIC(10,2))
	BEGIN
		IF IdDepartamento NOT IN (1,2,3,4) THEN
			RAISE EXCEPTION 'Id de departamento inválido'

			total_funcionarios := NULL;
        	total_salarios := NULL;
        	RETURN;
		END IF;

	SELECT COUNT(e.matricula), SUM(e.salario)
	INTO total_funcionarios, total_salarios
	FROM DEPARTAMENTO d
	JOIN EMPREGADO e ON d.coddep = e.depto
	WHERE d.coddep = idDepartamento
	
	END

15) Crie a SP que recebe o nome de um departamento e concede aumentos consecutivos de
5% para todos os funcionários, em cada uma das seguintes situações:
	A) O aumento é concedido pelo menos uma vez, mas só continua sendo dado enquanto a soma dos
	salários não ultrapassar R$30.000,00;
	B) O aumento só é concedido enquanto a soma dos salários não ultrapassar R$30.000;

CREATE PROCEDURE aumentos_consecutivos(IN nomeDepartamento TEXT)
DECLARE
    idDepartamento INT;
    somaTotalSalarios NUMERIC(10,2);
BEGIN
    SELECT coddep INTO idDepartamento
    FROM DEPARTAMENTO
    WHERE nome = nomeDepartamento;

    LOOP
        UPDATE EMPREGADO
        SET salario = salario * 1.05
        WHERE depto = idDepartamento;

        SELECT SUM(salario) INTO somaTotalSalarios
        FROM EMPREGADO
        WHERE depto = idDepartamento;

        EXIT WHEN somaTotalSalarios > 30000;
    END LOOP;

    RAISE NOTICE 'A soma final dos salários do departamento % é %', nomeDepartamento, somaTotalSalarios;
END;

16) Escreva a SP que recebe os nomes de dois departamentos e calcula a somas dos salários de cada departamento 
e quantos funcionários há em cada um. A SP deve calcular a média salarial de cada  departamento. 
Se as médias forem diferentes, o departamento de menor média deve passar a receber
média salarial igual ao de maior média, passando essa atualização para os salários dos empregados. Em
seguida, a SP deve retornar uma mensagem com a frase: “O departamento de nome XXX que possui YYY
funcionários recebeu um aumento salarial de ZZZ”, em que: XXX é o nome do departamento, YYY é a
quantidade de funcionários, e ZZZ é a quantidade de dinheiro a mais que o departamento passou a ganhar;

CREATE PROCEDURE informacoes_funcionarios_departamento(
    IN nomeDepartamento1 TEXT,
    IN nomeDepartamento2 TEXT,
    OUT mensagem TEXT
)
DECLARE
    idDepartamento1 INT;
    idDepartamento2 INT;
    somaSalarioDepartamento1 NUMERIC(10,2);
    somaSalarioDepartamento2 NUMERIC(10,2);
    quantidadeFuncionariosDepartamento1 INT;
    quantidadeFuncionariosDepartamento2 INT;
    mediaSalarialDepartamento1 NUMERIC(10,2);
    mediaSalarialDepartamento2 NUMERIC(10,2);
    aumentoSalarial NUMERIC(10,2);
BEGIN
    SELECT coddep INTO idDepartamento1
    FROM DEPARTAMENTO
    WHERE nome = nomeDepartamento1;

    SELECT coddep INTO idDepartamento2
    FROM DEPARTAMENTO
    WHERE nome = nomeDepartamento2;

    SELECT COUNT(matricula), SUM(salario), AVG(salario)
    INTO quantidadeFuncionariosDepartamento1, somaSalarioDepartamento1, mediaSalarialDepartamento1
    FROM EMPREGADO
    WHERE depto = idDepartamento1;

    SELECT COUNT(matricula), SUM(salario), AVG(salario)
    INTO quantidadeFuncionariosDepartamento2, somaSalarioDepartamento2, mediaSalarialDepartamento2
    FROM EMPREGADO
    WHERE depto = idDepartamento2;

    IF mediaSalarialDepartamento1 > mediaSalarialDepartamento2 THEN
        SET aumentoSalarial = (mediaSalarialDepartamento1 - mediaSalarialDepartamento2) * quantidadeFuncionariosDepartamento2;

        UPDATE EMPREGADO
        SET salario = mediaSalarialDepartamento1
        WHERE depto = idDepartamento2;

        SET mensagem = 'O departamento de nome ' || nomeDepartamento2
                    || ' que possui ' || quantidadeFuncionariosDepartamento2
                    || ' funcionarios recebeu um aumento salarial de ' || aumentoSalarial;

    ELSIF mediaSalarialDepartamento2 > mediaSalarialDepartamento1 THEN
        SET aumentoSalarial = (mediaSalarialDepartamento2 - mediaSalarialDepartamento1) * quantidadeFuncionariosDepartamento1;

        UPDATE EMPREGADO
        SET salario = mediaSalarialDepartamento2
        WHERE depto = idDepartamento1;

        SET mensagem = 'O departamento de nome ' || nomeDepartamento1
                    || ' que possui ' || quantidadeFuncionariosDepartamento1
                    || ' funcionarios recebeu um aumento salarial de ' || aumentoSalarial;

    ELSE
        SET mensagem = 'As médias salariais dos departamentos são iguais. Nenhum aumento aplicado.';
    END IF;
END;
