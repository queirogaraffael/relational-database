CREATE DATABASE sistemaDelivery;

CREATE TABLE Cliente(
	id_cliente SERIAL PRIMARY KEY,
	
	nome VARCHAR(30),
	cpf CHAR(11) UNIQUE
);

CREATE TABLE Funcionario(
	id_funcionario SERIAL PRIMARY KEY,
	
	nome VARCHAR(30),
	cpf CHAR(11) UNIQUE NOT NULL,
	telefone VARCHAR(13)
);

CREATE TABLE Entrega(
	id_entrega SERIAL PRIMARY KEY,
	
	id_funcionario INT,
	
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE RESTRICT
);

CREATE TABLE Feedback(
	id_feedback SERIAL PRIMARY KEY,
	
	id_cliente INT,
	id_entrega INT,
	
	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente) ON DELETE CASCADE,
	FOREIGN KEY(id_entrega) REFERENCES Entrega(id_entrega) ON DELETE CASCADE
);

CREATE TABLE Restaurante(
	id_restaurante SERIAL PRIMARY KEY,
	
	nome VARCHAR(40)
);

CREATE TABLE Comida(
	id_comida SERIAL PRIMARY KEY,
	
	id_restaurante INT, 
	name_comida VARCHAR(50),
	descricao VARCHAR(50),
	
	FOREIGN KEY(id_restaurante) REFERENCES Restaurante(id_restaurante) ON DELETE RESTRICT
);

CREATE TABLE Pedido(
	id_pedido SERIAL PRIMARY KEY,
	
	id_cliente INT,
	id_entrega INT,
	id_funcionario INT,
	data_pedido DATE,
	
	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente) ON DELETE CASCADE,
	FOREIGN KEY(id_entrega) REFERENCES Entrega(id_entrega) ON DELETE CASCADE,
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario) ON DELETE RESTRICT
);

CREATE TABLE PedidoComida(
	id_comida INT,
	id_pedido INT,
	
	descricao_prato VARCHAR(50),
	
	PRIMARY KEY(id_comida, id_pedido),
	
	FOREIGN KEY(id_comida) REFERENCES Comida(id_comida) ON DELETE RESTRICT,
	FOREIGN KEY(id_pedido) REFERENCES Pedido(id_pedido) ON DELETE CASCADE
);

