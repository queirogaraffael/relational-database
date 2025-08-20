CREATE DATABASE sistemaRH;

CREATE TABLE Pagamento(
	id_pagamento
	mesreferencia
	salario
	bonus

);
CREATE TABLE SolicitacaoFerias(
	id_solicita_ferias
	id_funcionario
	datainicio
	datafim
	datasolicitacao
	status

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Departamento(
	id_departamento
	nome
	descricao
);

CREATE TABLE TelefoneFuncionario(
	id_telefone_funcionario
	id_funcionario
	telefone

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE FuncionarioBeneficio(
	id_funcionario
	id_beneficio

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Beneficio(
	id_beneficio
	nome
	descricao
);

CREATE TABLE Funcionario(
	id_funcionario
	id_pagamento
	id_departamento
	
	nome
	cpf
	email
	datacontrtacao
	cargo
	salario
	rua
	numero_residencia
	bairro
	cidade

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)

);

CREATE TABLE RegistroHora(
	id_registra_hora
	id_funcionario
	id_projeto
	data_
	horastrabalhadas

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Funcionario_Projeto(
	id_funcionario
	id_projeto

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Projeto(
	id_projeto
	nome
	descricao
	datainicio
	datafim
	status
	
);
