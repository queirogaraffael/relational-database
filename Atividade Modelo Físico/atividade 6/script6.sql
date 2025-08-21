CREATE DATABASE sistemaRH;

CREATE TABLE Pagamento(
	id_pagamento SERIAL PRIMARY KEY,
	
	mes_referencia DATE,
	salario DECIMAL(10,2)
);

CREATE TABLE Projeto(
	id_projeto SERIAL PRIMARY KEY, 
	
	nome VARCHAR(30),
	descricao VARCHAR(100),
	datainicio DATE,
	datafim DATE,
	status VARCHAR(15)
	
);

CREATE TABLE Departamento(
	id_departamento SERIAL PRIMARY KEY,
	
	nome VARCHAR(30), 
	descricao VARCHAR(50)
);

CREATE TABLE Beneficio(
	id_beneficio SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	descricao VARCHAR(100)
);

CREATE TABLE Funcionario(
	id_funcionario SERIAL PRIMARY KEY,
	
	id_pagamento INT NOT NULL,
	id_departamento INT NOT NULL,
	
	nome VARCHAR(50),
	cpf VARCHAR(11) UNIQUE NOT NULL,
	email VARCHAR(20),
	data_contratacao DATE, 
	cargo VARCHAR(20),
	salario DECIMAL(10,2),

	FOREIGN KEY(id_pagamento) REFERENCES Pagamento(id_pagamento) ON DELETE RESTRICT,
	FOREIGN KEY(id_departamento) REFERENCES Departamento(id_departamento) ON DELETE RESTRICT

);

CREATE TABLE SolicitacaoFerias(
	id_solicita_ferias SERIAL PRIMARY KEY,
	
	id_funcionario INT NOT NULL, 
	
	datainicio DATE,
	datafim DATE, 
	datasolicitacao DATE,
	status VARCHAR(15),

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE CASCADE
);

CREATE TABLE TelefoneFuncionario(
	id_telefone_funcionario SERIAL PRIMARY KEY,
	id_funcionario INT,
	telefone VARCHAR(13),

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE CASCADE
);

CREATE TABLE FuncionarioBeneficio(
	id_funcionario INT NOT NULL,
	id_beneficio INT NOT NULL,

	PRIMARY KEY(id_funcionario, id_beneficio),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE CASCADE,
	FOREIGN KEY(id_beneficio) REFERENCES Beneficio(id_beneficio) ON DELETE CASCADE
);

CREATE TABLE RegistroHora(
	id_registroHora SERIAL PRIMARY KEY,
	
	id_funcionario INT NOT NULL,
	id_projeto INT NOT NULL, 
	
	data_registro DATE,
	horastrabalhadas INT,

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE CASCADE,
	FOREIGN KEY(id_projeto) REFERENCES Projeto(id_projeto) ON DELETE CASCADE

);

CREATE TABLE Funcionario_Projeto(
	id_funcionario INT NOT NULL,
	id_projeto INT NOT NULL,

	PRIMARY KEY(id_funcionario, id_projeto),

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE CASCADE,
	FOREIGN KEY(id_projeto) REFERENCES Projeto(id_projeto) ON DELETE CASCADE

);

