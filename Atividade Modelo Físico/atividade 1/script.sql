CREATE DATABASE sistemaVendas;

USE sistemaVendas;

CREATE TABLE Categoria(
	id_categoria INT NOT NULL AUTO_INCREMENT,
	nome_categoria VARCHAR(30) NOT NULL,
	descricao VARCHAR(100),

	PRIMARY KEY (id_categoria)
);

CREATE TABLE Produto(
	id_produto INT NOT NULL AUTO_INCREMENT,
	nome_produto VARCHAR(50) NOT NULL,
	preco DECIMAL(10,2),
	quantidade INT,

	PRIMARY KEY (id_produto)
);


CREATE TABLE ProdutoCategoria(
	id_produto INT NOT NULL,
	id_categoria INT NOT NULL,

	PRIMARY KEY(id_produto, id_categoria),

	FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
	FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);

CREATE TABLE Cliente(
	id_cliente INT NOT NULL AUTO_INCREMENT,
	nome VARCHAR(60) NOT NULL,
	cpf VARCHAR(11) NOT NULL UNIQUE,	

	PRIMARY KEY(id_cliente)
);


CREATE TABLE Pedido(
	id_pedido INT NOT NULL AUTO_INCREMENT,
	id_cliente INT NOT NULL,

	data_pedido DATETIME NOT NULL,
	data_pagamento TIMESTAMP,
	valor_total DECIMAL(10,2) NOT NULL,
	valor_frete DECIMAL(10,2),
	status VARCHAR(20) NOT NULL,
	avaliacao DECIMAL(10,2),

	PRIMARY KEY(id_pedido), 
	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE ItemPedido(
	id_produto INT NOT NULL,
	id_pedido INT NOT NULL,
	quantidade INT, 
	preco DECIMAL(10,2),

	PRIMARY KEY(id_produto, id_pedido),
	FOREIGN KEY (id_produto) REFERENCES Produto(id_produto),
	FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);