----- Tabela -----

Setor(Numero, NomeSet)
Fornecedor(Registro, NomeReg)
Item(Codigo, Descricao, Preco, RegForn, NumSet)
Atendente(Cpf, Nome, Salario, Endereco, Sexo, SetNum)
Venda(AtCpf, CodIt, NotaFiscal, Volume, DtVenda)

----- Exercicios GROUP BY -----

1) Por setor, mostre o código do setor, a quantidade de itens que possui, o
item mais caro e o mais barato (use apenas uma tabela);

SELECT it.SetNUM, MAX(it.Preco), MIN(it.Preco)
FROM ITEM it
GROUP BY it.SetNum

2) Para cada atendente, liste a quantidade de vendas feitas, a quantidade
total de volumes que vendeu (soma de Volume), e a média de vendas feitas
(média dos volumes) (use apenas uma tabela);

SELECT v.AtCpf, COUNT(v.CodIt), SUM(v.Volume), AVG(v.Volume)
FROM Venda v
GROUP BY v.AtCpf

3) Para cada setor, mostre o nome e o código do setor, e a soma dos salários
dos pessoas do sexo feminino com salário cadastrado e que não sejam do
setor de Sucos;

SELECT s.NomeSet, s.Numero, SUM(a.salario)
FROM SETOR s
JOIN ATENDENTE a ON s.Numero = a.SetNum
WHERE a.Sexo = 'feminino' 
	AND NOT s.NomeSet = 'Sucos'
	AND a.salario IS NOT NULL;
GROUP BY s.NomeSet, s.Numero;

4) Para cada fornecedor, mostre o registro do fornecedor, o nome dele, os
nomes dos itens que ele fornece, exceto os itens que são do setor de hortifrutigranjeiro;

SELECT f.Registro, f.NomeReg, STRING_AGG(it.Descricao, ', ') AS itens 
FROM FORNECEDOR f
JOIN Item it ON f.Registro = it.RegForn
JOIN SETOR s ON it.NumSet = s.Numero
WHERE s.NomeSet IS != 'hortifrutigranjeiro'
GROUP BY f.Registro, f.NomeReg;

5) Para cada setor, mostre o número e o nome do setor, e mostre a de nomes
lista de itens presentes nesse setor;

SELECT s.numero, s.nome, STRING_AGG(it.Descricao, ', ') AS itens
FROM SETOR s
JOIN ITEM it ON s.numero = it.NumSet
GROUP BY s.numero, s.nome;

6) Para cada setor, mostre o nome do setor, a lista de nomes e endereços de
atendentes que trabalham no setor, e quantas vendas este vendedor fez;

SELECT 
    s.NomeSet,
    a.Nome || ' - ' || a.Endereco AS atendente_com_endereco,
    COUNT(v.AtCpf) AS total_vendas
FROM SETOR s 
JOIN ATENDENTES a ON s.numero = a.SetNum
LEFT JOIN VENDAS v ON a.Cpf = v.AtCpf
GROUP BY s.NomeSet, a.Nome, a.Endereco;

7) Para cada setor, mostre o nome do setor, uma lista de nomes dos itens do
setor, e uma lista de nomes atendentes que já venderam aquele item;

SELECT s.nome, STRING_AGG(DISTINCT it.Descricao, ',') AS itens_setor, STRING_AGG(DISTINCT a.Nome, ', ') AS atendentes_que_ja_venderam
FROM SETOR s
JOIN ITEM it ON s.numero = it.NumSet
JOIN VENDA v ON it.codigo = v.codit
JOIN ATENDENTE a ON v.AtCpf = a.Cpf
GROUP BY s.nome;
