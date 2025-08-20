CREATE DATABASE sistemaHotelaria;

CREATE TABLE Quarto(
	id_quarto SERIAL PRIMARY KEY,
	
	numero INT NOT NULL,
	capacidade INT NOT NULL, 
	preco DECIMAL(10,2)
);

CREATE TABLE ServicoOpcional(
	id_servico SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	preco DECIMAL(10,2),
	descricao VARCHAR(50)
);

CREATE TABLE ServicoFixo(
	id_servicoFixo SERIAL PRIMARY KEY,
	
	nome VARCHAR(30),	
	preco DECIMAL(10,2),
	descricao VARCHAR(50)
);

CREATE TABLE Funcionario(
	id_funcionario SERIAL PRIMARY KEY,
	
	nome VARCHAR(50),
	cpf VARCHAR(11) UNIQUE,
	email VARCHAR(50),
	cargo VARCHAR(30),
	telefone VARCHAR(12)
);

CREATE TABLE Hospede(
	id_hospede SERIAL PRIMARY KEY,
	
	cpf VARCHAR(11) UNIQUE,
	telefone VARCHAR(11)
);

CREATE TABLE Reserva(
	id_reserva SERIAL PRIMARY KEY,
	
	id_hospede INT,
	id_funcionario INT,
	
	data_reserva DATE NOT NULL, 
	data_checkin DATE,
	data_checkout DATE,
	status_reserva VARCHAR(20),

	FOREIGN KEY(id_hospede) REFERENCES Hospede(id_hospede),
	FOREIGN KEY(id_funcionario) REFERENCES Funcionario(id_funcionario)

);

CREATE TABLE ServicoFixo_Quarto(
	id_servicoFixo INT NOT NULL,
	id_quarto INT NOT NULL,

	PRIMARY KEY(id_servicoFixo, id_quarto),
	FOREIGN KEY(id_servicoFixo) REFERENCES ServicoFixo(id_servicoFixo),
	FOREIGN KEY(id_quarto) REFERENCES Quarto(id_quarto)


);

CREATE TABLE QuartoReserva(
	id_quarto INT NOT NULL,
	id_reserva INT NOT NULL,
	
	PRIMARY KEY(id_quarto, id_reserva),
	FOREIGN KEY(id_quarto) REFERENCES Quarto(id_quarto),
	FOREIGN KEY(id_reserva) REFERENCES Reserva(id_reserva)
);


CREATE TABLE ServicoReserva(
	id_servicoOpcional INT NOT NULL, 
	id_reserva INT NOT NULL, 
	quantidade INT,

	PRIMARY KEY(id_servicoOpcional, id_reserva),
	FOREIGN KEY(id_servicoOpcional) REFERENCES ServicoOpcional(id_servico),
	FOREIGN KEY(id_reserva) REFERENCES Reserva(id_reserva)

);