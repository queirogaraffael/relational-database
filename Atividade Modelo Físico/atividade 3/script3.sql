CREATE DATABASE sistemaBiblioteca;

CREATE TABLE Autor(
id_autor
nome
nacionalidade
biografia
);

CREATE TABLE AutorLivro(
id_auto
id_livro
);

CREATE TABLE Livro(
id_livro
id_editora(fk)

titulo
genero
numero_paginas
ano_publicacao

);
CREATE TABLE Editora(
id_editora
nome
site
email
);


CREATE TABLE Devolucao(
id_devolucao
id_cliente
id_funcionario
id_livro

data_devolucao
multa

);

CREATE TABLE livroEmprestimo(
id_livro
id_emprestimo

);
CREATE TABLE Funcionario(
id_funcionario
nome
cargo
telefone
);
CREATE TABLE Emprestimo(
id_emprestimo
id_cliente
id_funcionario

data_emprestimo
data_prevista_devolucao
status
);
CREATE TABLE Cliente(
id_cliente
nome
data_nascimento
email
);