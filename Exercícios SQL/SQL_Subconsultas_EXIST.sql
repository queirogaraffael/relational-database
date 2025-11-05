----- Tabela -----

Funcionário(Matrícula, Nome, Endereço, Salario, Cpf, DtNasc, DtAdm)
Setor(Número, Nome, MatGer)
TrabalhaEm(MatFunc, NumSet, Turno)
Cargo(Registro, Nome, Descrição, ValorHora)
Função(FuncMat, CargReg, HorasMensais)
Item(Código, Nome, Preço, Validade, SetNum)
Venda(Mat, CodIt, NotaFiscal, Qtd, DtVenda)

----- Exercicios -----

1) Retorne o nome e CPF dos funcionários que trabalham no turno da manhã ou da noite e que estão em 
cargos cujo ValorHora é menor do que R$30.00;

SELECT f.nome, f.cpf
FROM FUNCIONARIO f
JOIN TrabalhaEm te ON f.matricula = te.matFunc
JOIN Funcao fun ON f.matricula = func.FuncMat 
JOIN Cargo c ON fun.CargReg = c.Registro
WHERE (te.turno = 'manhã' OR te.turno = 'noite') AND c.ValorHora < 30.00;

2) Liste o código e nome dos itens que possuem preço maior do que R$50.00, que foram vendidos
com quantidade menor do que 40, que são do mesmo setor de funcionários que estão em cargos com
ValorHora maior ou igual a R$36.00; (vai ser preciso usar consulta aninhada nesta questão)

SELECT it.codigo, it.nome
FROM ITEM it 
JOIN VENDA v ON it.codigo = v.CodIt
WHERE it.preco > 50.00 
		AND v.QTD < 40 
		AND EXISTS (
									SELECT 1
									FROM FUNCIONARIO f
									JOIN TrabalhaEm te ON f.matricula = te.MatFunc 
									JOIN FUNCAO func ON f.matricula = func.FuncMat
									JOIN CARGO c ON func.CargReg = c.Registro
									WHERE c.ValorHora >= 36.00 AND te.NumSet = it.SetNum
);

----- EXISTS E/OU NOT EXISTS -----

3) Escreva o comando SQL que mostra o nome e número dos setores que não possuem
funcionários trabalhando no turno da noite, mas apenas das pessoas que não têm 
endereço cadastrado, considerando apenas os setores com gerente cadastrado;

SELECT s.nome, s.numeros
FROM SETOR s
WHERE s.MatGer IS NOT NULL AND NOT EXISTS (SELECT 1
				FROM FUNCIONARIO f
				JOIN TRABALHAEM te ON f.matricula = te.MatFunc
				WHERE f.endereco IS NULL AND te.turno = 'noite'
						AND te.NumSET = s.Numero)

4) Obtenha o nome e endereço dos funcionários que recebem salário maior do que R$1500.00,
mas apenas dos funcionários com data de nascimento cadastrada;

SELECT f.nome, f.endereco
FROM FUNCIONARIO f
WHERE EXISTS (SELECT 1
				FROM FUNCIONARIO f2
				WHERE f.matricula = f2.matricula
					AND f2.salario > 1500.00 
					AND f2.DTNasc IS NOT NULL);

5) Mostre o código, nome e preço dos itens que estão no setor de ‘Açougue’, 
mas que nunca foram vendidos com quantidades maiores do que 20, mas considere só os itens com preço cadastrado;

SELECT it.codigo, it.nome, it.preco
FROM ITEM it
WHERE 	it.Preco IS NOT NULL 

		AND EXISTS (SELECT 1
				FROM SETOR s
				WHERE s.nome = 'Açougue' AND s.numero = it.setnum)
				
		AND NOT EXISTS (SELECT 1
						FROM VENDA v
						WHERE v.Qtd > 20 AND it.codigo = v.codIt
		);