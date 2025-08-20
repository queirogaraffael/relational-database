CREATE DATABASE sistemaDelivery;

CREATE TABLE Cliente(
	id_cliente
	nome
	cpf
	rua
	bairro
	numero_residencia
	numero_telefone
);

CREATE TABLE Feedback(
	id_feedback
	
	id_cliente
	id_entrega

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Entrega(
	id_entrega
	id_funcionario

	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Pedido(
	id_pedido
	id_cliente
	id_entrega
	id_funcionario
	data_pedido

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Funcionario(
	id_funcionario
	nome
	cpf
	telefone
	rua
	numero
	bairro
	cidade
);

CREATE TABLE PedidoComida(
	id_comida
	id_pedido
	descricao_prato

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)
);

CREATE TABLE Comida(
	id_comida
	id_restaurante
	name_
	descricao

	FOREIGN KEY(id_cliente) REFERENCES Cliente(id_cliente),
);

CREATE TABLE Restaurante(
	id_restaurante
	nome
	cardapio
);
