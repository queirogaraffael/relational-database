CREATE DATABASE sistemaAcademia;

CREATE TABLE Departamento(
	id_departamento SERIAL PRIMARY KEY,
	
	nome VARCHAR(30),
	codigo VARCHAR(10),
	email VARCHAR(30),
	telefone VARCHAR(12)
);

CREATE TABLE Curso(
	id_curso SERIAL,
	id_departamento INT NOT NULL,
	nome VARCHAR(30),
	codigo VARCHAR(10) UNIQUE,
	duracao int,

	PRIMARY KEY(id_curso),
	FOREIGN KEY(id_departamento) REFERENCES Departamento(id_departamento)
);

CREATE TABLE Aluno(
	id_aluno SERIAL,
	id_curso INT,
	
	nome VARCHAR(60),
	matricula VARCHAR(10) UNIQUE,
	data_nascimento DATE,
	email VARCHAR(50), 
	telefone VARCHAR(12),

	PRIMARY KEY(id_aluno),
	FOREIGN KEY(id_curso) REFERENCES Curso(id_curso)

);

CREATE TABLE Professor(
	id_professor SERIAL PRIMARY KEY,
	id_departamento INT,
	
	nome VARCHAR(50),
	email VARCHAR(50),
	telefone VARCHAR(12),
	salario DECIMAL(10,2),

	FOREIGN KEY (id_departamento) REFERENCES Departamento(id_departamento)
);

CREATE TABLE Disciplina(
	id_disciplina SERIAL,
	
	nome VARCHAR(30),
	codigo VARCHAR(10) UNIQUE,
	carga_horaria INT,

	PRIMARY KEY(id_disciplina)
);


CREATE TABLE aluno_disciplina(
	id_aluno INT,
	id_disciplina INT,

	PRIMARY KEY(id_aluno, id_disciplina),
	FOREIGN KEY (id_aluno) REFERENCES Aluno(id_aluno),
	FOREIGN KEY (id_disciplina) REFERENCES Disciplina(id_disciplina)
);

CREATE TABLE NotaAluno(
	id_nota_aluno SERIAL,
	id_professor INT,
	id_disciplina INT,
	id_aluno INT,
	
	nota DECIMAL(10,2),

	PRIMARY KEY(id_nota_aluno),
	FOREIGN KEY (id_professor) REFERENCES Professor(id_professor),
	FOREIGN KEY (id_disciplina) REFERENCES Disciplina(id_disciplina),
	FOREIGN KEY (id_aluno) REFERENCES Aluno(id_aluno)

);

CREATE TABLE disciplina_professor(
	id_disciplina INT,
	id_professor INT,

	PRIMARY KEY(id_disciplina, id_professor),
	FOREIGN KEY (id_disciplina) REFERENCES Disciplina(id_disciplina),
	FOREIGN KEY (id_professor) REFERENCES Professor(id_professor)
);

