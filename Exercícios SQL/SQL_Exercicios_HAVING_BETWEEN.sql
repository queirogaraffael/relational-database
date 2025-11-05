----- Tabela -----

Setor(Numero, NomeSet)
Fornecedor(Registro, NomeReg)
Item(Codigo, Descricao, Preco, RegForn, NumSet)
Atendente(Cpf, Nome, Salario, Endereco, Sexo, SetNum)
Venda(AtCpf, CodIt, NotaFiscal, Volume, DtVenda)

----- Exercicios HAVING, BETWEEN, LIKE, OPERAÇÕES ARITMÉTICAS, INSERT E DELETE -----

1) Para cada atendente, mostre o nome do atendente, a lista de itens que ele
já vendeu e a quantidade de vendas que ele já vez de cada item (lembre-se
de que uma venda é uma tupla de uma tabela), mas apenas para os itens
com preço entre 10.00 e 50.00, vendidos 5 vezes ou mais;

SELECT a.nome, it.Descricao, COUNT(v.volume)
FROM ATENDENTE a 
JOIN VENDA v ON a.cpf = v.AtCpf
JOIN ITEM it ON v.CodIt = it.codigo
WHERE it.preco BETWEEN 10.00 AND 50.00
GROUP BY a.cpf, a.nome, it.codigo, it.Descricao
HAVING COUNT(v.volume) >= 5;

2) Mostre a descrição do item, e o preço dele, mas apenas para os itens de
cuja soma dos volumes das vendas seja maior do que 30, listando pela
descrição de A para Z e pelos preços do maior pro menor;

SELECT it.descricao, it.preco, SUM(v.volume)
FROM ITEM it
JOIN VENDA v ON it.codigo = v.CodIt
GROUP BY it.descricao, it.preco
HAVING COUNT(v.volume) > 30
ORDER BY it.descricao ASC , it.preco DESC

3) Simule um desconto de 5% dos preços dos itens de todos os setores,
exceto os do setor de vestuário e que estão sem preço cadastrado;

SELECT it.preco * 0.95 
FROM SETOR s
JOIN ITEM it ON s.numero = it.NumSet
WHERE s.NomeSet != 'vestuario' 
	AND it.preco IS NOT NULL;

4) Liste todos os vendedores que têm o último sobrenome como sendo
Cavalcante ou Cavalcanti, liste a descrição de todos os itens que eles já
venderam e mostre quanto ficaria o preço de cada um desses itens se
fosse dado um aumento de 3% nos preços deles;

SELECT a.nome, it.Descricao, it.preco * 1.03
FROM ATENDENTE a
JOIN VENDA v ON a.cpf = v.AtCpf
JOIN ITEM it ON v.CodIt = it.codigo
WHERE a.Nome LIKE '%Cavalcante' OR a.Nome LIKE '%Cavalcanti';

5) Delete todos os vendedores do setor de Frios. Depois delete os atendentes
que moram em avenidas;

DELETE 
FROM ATENDENTE a
WHERE a.SetNum IN (SELECT s.Numero FROM SETOR s WHERE s.NomeSet = 'frios')

DELETE 
FROM ATENDENTE a
WHERE a.endereco LIKE '%avenida%';

6) Insira dois novos setores, com os dados {20, ‘Eletro’} e {21, ‘Pneus e
peças’};

INSERT INTO SETOR(Numero, NomeSet) 
VALUES 
	(20, ‘Eletro’), 
	(21, ‘Pneus e peças’);

7) Crie uma nova tabela chamada TotVendas que vai ser uma totalização das
vendas feitas por cada atendente, com os seguintes campos: o CPF do
atendente, o nome do atendente e a quantidade de vendas que ele já fez.
Depóis preencha essa tabela usando um INSERT INTO com um comando
SELECT;

CREATE TABLE TotVendas(
	Cpf VARCHAR(11) PRIMARY KEY,
	NomeAtendente VARCHAR(50),
	Quantidade INT,

	CONSTRAINT fk_atendente FOREIGN KEY(Cpf) REFERENCES ATENDENTE(Cpf)
);

INSERT INTO TotVendas()
VALUES 
	('', '', 10),
	('', '', 20);