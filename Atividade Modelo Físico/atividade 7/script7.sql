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
);

CREATE TABLE Entrega(
id_entrega
id_funcionario

);
CREATE TABLE Pedido(
id_pedido
id_cliente
id_entrega
id_funcionario
data_pedido

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
);
CREATE TABLE Comida(
id_comida
id_restaurante
name
descricao

);
CREATE TABLE Restaurante(
id_restaurante
nome
cardapio

);
