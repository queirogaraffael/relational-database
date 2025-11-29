-- TABELA EMPREGADO
CREATE TABLE EMPREGADO (
    matricula INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(100),
    salario NUMERIC(10, 2),
    supervisor INTEGER,
    depto VARCHAR(3),
    sexo CHAR(1),
    FOREIGN KEY (supervisor) REFERENCES EMPREGADO(matricula),
    FOREIGN KEY (depto) REFERENCES DEPARTAMENTO(coddep)
);

-- Dados para EMPREGADO
INSERT INTO EMPREGADO (matricula, nome, endereco, salario, supervisor, depto, sexo) VALUES
(100, 'Ana Ananias Alves', 'Rua do Amarelo, n 1', 1200.00, 100, 'd1', 'F'),
(101, 'Bernardo Borges Brasão', 'Rua do Branco, n 2', 900.00, 101, 'd2', 'M'),
(102, 'Cleiton Carmelo Cruz', 'Praça do Cinza, n 3', 800.00, 100, 'd1', 'M'),
(103, 'Diego Dorneles', 'Avenida do Damasco, n 4', 900.00, 100, 'd1', 'M'),
(104, 'Érika Esdras', 'Rua do Enferrujado, n 5', 700.00, 104, 'd3', 'F');


-- TABELA DEPARTAMENTO
CREATE TABLE DEPARTAMENTO (
    coddep VARCHAR(3) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    gerente INTEGER,
    dataini DATE,
    FOREIGN KEY (gerente) REFERENCES EMPREGADO(matricula)
);

-- Dados para DEPARTAMENTO
INSERT INTO DEPARTAMENTO (coddep, nome, gerente, dataini) VALUES
('d1', 'Sistemas', 100, '2000-01-01'),
('d2', 'Física', 101, '2004-01-01'),
('d3', 'Matemática', 104, '2002-01-01');


-- TABELA PROJETO
CREATE TABLE PROJETO (
    codproj INTEGER PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    local VARCHAR(50),
    depart VARCHAR(3),
    FOREIGN KEY (depart) REFERENCES DEPARTAMENTO(coddep)
);

-- Dados para PROJETO
INSERT INTO PROJETO (codproj, nome, local, depart) VALUES
(1, 'Projeto1', 'Campina Grande', 'd1'),
(2, 'Projeto2', 'Patos', 'd2'),
(3, 'Projeto3', 'Fortaleza', 'd2'),
(4, 'Projeto4', 'Campina Grande', 'd1'),
(5, 'Projeto5', 'Patos', 'd1'),
(6, 'Projeto6', 'Natal', 'd2'),
(7, 'Projeto7', 'Natal', 'd3');


-- TABELA ALOCACAO (Tabela de Relacionamento N:M entre EMPREGADO e PROJETO)
CREATE TABLE ALOCACAO (
    matric INTEGER,
    codproj INTEGER,
    horas INTEGER,
    PRIMARY KEY (matric, codproj),
    FOREIGN KEY (matric) REFERENCES EMPREGADO(matricula),
    FOREIGN KEY (codproj) REFERENCES PROJETO(codproj)
);

-- Dados para ALOCACAO
INSERT INTO ALOCACAO (matric, codproj, horas) VALUES
(100, 1, 5),
(104, 7, 5),
(100, 3, 10),
(103, 2, 5),
(100, 6, 2),
(101, 4, 5),
(102, 5, 10);


-- TABELA DEPENDENTE
CREATE TABLE DEPENDENTE (
    coddepend INTEGER,
    mat INTEGER,
    nome VARCHAR(100) NOT NULL,
    sexo CHAR(1),
    PRIMARY KEY (coddepend, mat),
    FOREIGN KEY (mat) REFERENCES EMPREGADO(matricula)
);

-- Dados para DEPENDENTE
INSERT INTO DEPENDENTE (coddepend, mat, nome, sexo) VALUES
(1, 101, 'Bernardo Borges Brasão', 'M'),
(2, 101, 'Beatriz Borges Brasão', 'F'),
(1, 104, 'Eduardo Esdras Euler', 'M'),
(1, 103, 'Dayse Dorneles', 'F');