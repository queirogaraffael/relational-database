CREATE DATABASE sistemaVendas;

CREATE TABLE Categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(30) NOT NULL,
    descricao VARCHAR(100)
);

CREATE TABLE Produto (
    id_produto SERIAL PRIMARY KEY,
    nome_produto VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    quantidade INT
);

CREATE TABLE ProdutoCategoria (
    id_produto INT NOT NULL,
    id_categoria INT NOT NULL,
	
    PRIMARY KEY (id_produto, id_categoria),
	
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);

CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
	
    nome VARCHAR(60) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE
);

CREATE TABLE Pedido (
    id_pedido SERIAL PRIMARY KEY,
	
    id_cliente INT NOT NULL,
	
    data_pedido TIMESTAMP NOT NULL,
    data_pagamento TIMESTAMP,
    valor_total DECIMAL(10,2) NOT NULL,
    valor_frete DECIMAL(10,2),
    status VARCHAR(20) NOT NULL,
    avaliacao DECIMAL(10,2),
	
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE RESTRICT
);

CREATE TABLE ItemPedido (
    id_produto INT NOT NULL,
    id_pedido INT NOT NULL,
	
    quantidade INT,
    preco DECIMAL(10,2),
	
    PRIMARY KEY (id_produto, id_pedido),
	
    FOREIGN KEY (id_produto) REFERENCES Produto(id_produto) ON DELETE CASCADE,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido) ON DELETE CASCADE
);
