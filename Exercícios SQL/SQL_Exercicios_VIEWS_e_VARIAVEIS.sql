----- Views  e Variáveis -----

SerHumano(Matricula, Nome, Endereco, Salario, Telefone)
Motorista(MotMatricula, Cnh)
- MotMat referencia SerHumano
Cobrador(CobMatricula, CargaHoraria)
- CobMat referencia SerHumano
Tipo (Id, Descricao, Preco)
- A tabela Tipo guarda se o tipo de pagamento foi de Passagem inteira ou só Meia passagem.
- Assuma que o valor de inteira é 4,00 e meia é 2,00.
Pagamento (Registro, IdTipo, MatMotorista, MatCobrador, Dia, Mês, Ano)
Faturado (MatMotorista, MatCobrador, DiaD, MesM, AnoA, TotalDia)
Recados (Numero, Msg)

-----
 
01) Escreva a visão que, para cada motorista, mostra a matrícula do motorista, o nome, 
a CNH e quanto ele já faturou para a empresa, ordenando pela matrícula do motorista;

CREATE VIEW informacoes_motorista AS
SELECT sh.Matricula, sh.Nome, m.Cnh, SUM(f.TotalDia)
FROM MOTORISTA m
JOIN SerHumano sh ON m.MotMatricula = sh.Matricula
JOIN FATURADO f ON sh.Matricula = f.MatMotorista
GROUP BY sh.Matricula, sr.Nome, m.Cnh
ORDER BY sh.Matricula;

02) Usando visões, para cada tipo de passagem, mostre quantas passagens já foram pagas 
com cada uma delas, o total somado, e a média de lucro;

CREATE VIEW informacoes_passagens AS
SELECT t.Id, COUNT(p.IdTipo), SUM(t.preco), AVG(t.preco)
FROM TIPO t
JOIN PAGAMENTO p ON t.Id = p.IdTipo
GROUP BY t.Id;

03) Descubra qual a soma do TotalDia dos motorista que circularam na data 01/01/2020. 
Depois descubra qual a soma de TotalDia dos cobradores que receberam pagamentos de 
passagens inteiras (‘inteira’ é a descrição do tipo de pagamento feito). Em seguida 
faça a soma, subtração, multiplicação e divisão entre esses valores, guardando cada 
resultado em uma variável;

DECLARE @somaTotalDiaMotoristas INT;

SELECT @somaTotalDiaMotoristas = SUM(f.TotalDia)
FROM MOTORISTA m
JOIN FATURAMENTO f ON m.MotMatricula = f.MatMotorista
WHERE f.DiaD = 1 AND f.MesM = 1 AND f.AnoA = 2020;

DECLARE @somaTotalDiaCobradoresInteiras INT;

SELECT @somaTotalDiaCobradoresInteiras = SUM(f.TotalDia)
FROM COBRADOR c
JOIN FATURAMENTO f ON c.CobMatricula = f.MatCobrador
JOIN PAGAMENTO p ON f.MatCobrador = p.MatCobrador
JOIN TIPO t ON p.IdTipo = t.Id
WHERE f.DiaD = 1 AND f.MesM = 1 AND f.AnoA = 2020 AND t.descrcicao = 'inteira';

DECLARE @soma INT;
DECLARE @subtracao INT;
DECLARE @multiplicacao INT;
DECLARE @divisao NUMERIC;

SET @soma = @somaTotalDiaMotoristas + @somaTotalDiaCobradoresInteiras;
SET @subtracao = @somaTotalDiaMotoristas - @somaTotalDiaCobradoresInteiras;
SET @multiplicacao = @somaTotalDiaMotoristas * @somaTotalDiaCobradoresInteiras;
SET @divisao = @somaTotalDiaMotoristas / @somaTotalDiaCobradoresInteiras;

----- Tabela -----

Time(Codigo, NomeTime, Mascote, DtFundação)
Partida(Identificador, TimeA, TimeB, GolsA, GolsB, Dt)
Jogador(Cpf, NomeJog, DtNascimento, Salario, CodTime)

-----

04) Crie uma visão contendo o nome do jogador, salário, o código do 
seu time e o nome do time;

CREATE VIEW informacoes_jogador AS
SELECT j.nome, j.salario, j.CodTime, t.NomeTime
FROM JOGADOR j
JOIN Time t ON j.CodTime = t.Codigo;

05) Crie uma visão contendo o nome do time, o mascote, a quantidade de 
jogadores e a média de salários para todos os times cadastrados;

CREATE VIEW jogador_time AS
SELECT t.NomeTime, t.Mascote, COUNT(j.Cpf) AS quantidade_jogador, AVG(j.salario) AS media_salarial
FROM TIME t
JOIN JOGADOR j ON t.Codigo = j.CodTime
GROUP BY  t.NomeTime, t.Mascote;

06) Crie uma visão que mostre todas as partidas do dia 15/05/2010,
mostrando o nome e gols do Time A e nome e gols do Time B);

CREATE VIEW informacoes_partidas_dia_15_05_2010 AS
SELECT tA.NomeTime, p.GolsA, tB.NomeTime, p.GolsB
FROM PARTIDA p
JOIN TIME tA ON p.TimeA = tA.Codigo
JOIN TIME tB ON p.TimeB = tB.Codigo
WHERE p.Dt = '2010-05-15';
