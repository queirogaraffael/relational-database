CREATE DATABASE sistemaHotelaria;

CREATE TABLE ServicoFixo(
id_servicoFixo
nome
preco
descricao
);

CREATE TABLE ServicoFixo_Quarto(
id_servicoFixo
id_quarto

);

CREATE TABLE Quarto(
id_quarto
numero
capacidade
preco
);

CREATE TABLE QuartoReserva(
id_quarto
id_reserva
);

CREATE TABLE ServicoOpcional(
id_servico
nome
preco
descricao
);

CREATE TABLE ServicoReserva(
id_reservaOpcional(fk)
id_reserva
quantidade

);
CREATE TABLE Reserva(
id_reserva
id_hospde
id_funcionario
data_reserva
status
data_pagamento
data_checkin
data_chckout

);
CREATE TABLE Funcionario(
id_funcionario
nome
cpf
email
cargo
telefone

);
CREATE TABLE Hospede(
id_hospede
cpf
telefone
rua
numero
bairro
cidade
);