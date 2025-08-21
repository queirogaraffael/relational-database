CREATE DATABASE sistemaBiblioteca;

CREATE TABLE Autor(
	id_autor SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	nacionalidade VARCHAR(15),
	biografia VARCHAR(200)
);

CREATE TABLE Funcionario(
	id_funcionario SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	cargo VARCHAR(50),
	telefone VARCHAR(12)
);

CREATE TABLE Cliente(
	id_cliente SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	data_nascimento DATE,
	email VARCHAR(50)
);

CREATE TABLE Emprestimo(
	id_emprestimo SERIAL PRIMARY KEY, 
	
	id_cliente INT,
	id_funcionario INT NULL,
	
	data_emprestimo DATE,
	data_prevista_devolucao DATE,
	status VARCHAR(20),

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente) ON DELETE RESTRICT,
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE SET NULL
);

CREATE TABLE Editora(
	id_editora SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	site VARCHAR(30),
	email VARCHAR(30)
);

CREATE TABLE Livro(
	id_livro SERIAL PRIMARY KEY,
	id_editora INT,
	
	titulo VARCHAR(50),
	genero VARCHAR(20),
	numero_paginas INT,
	ano_publicacao INT,

	FOREIGN KEY(id_editora) REFERENCES Editora(id_editora) ON DELETE RESTRICT
);

CREATE TABLE Devolucao(
	id_devolucao serial PRIMARY KEY, 
	
	id_cliente INT,
	id_funcionario INT NULL,
	id_livro INT,
	
	data_devolucao DATE,
	multa DECIMAL(10,2),

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente) ON DELETE RESTRICT,
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE SET NULL,
	FOREIGN KEY(id_livro) REFERENCES Livro(id_livro) ON DELETE RESTRICT
);

CREATE TABLE AutorLivro(
	id_autor INT,
	id_livro INT,

	PRIMARY KEY(id_autor, id_livro), 
	
	FOREIGN KEY(id_autor) REFERENCES Autor(id_autor) ON DELETE CASCADE,
	FOREIGN KEY(id_livro) REFERENCES Livro(id_livro) ON DELETE CASCADE
);

CREATE TABLE livroEmprestimo(
	id_livro INT,
	id_emprestimo INT,

	PRIMARY KEY(id_livro, id_emprestimo),
	
	FOREIGN KEY(id_livro) REFERENCES Livro(id_livro) ON DELETE CASCADE,
	FOREIGN KEY(id_emprestimo) REFERENCES Emprestimo(id_emprestimo) ON DELETE CASCADE
);
