# Exercício 6 - Normalização 

## Praticando 
### Exercícios - Conjunto de Tabelas Não Normalizadas

Abaixo segue as seguintes tabelas não normalizadas, contendo informações sobre pedidos, produtos e clientes. Deverão normalizar essas tabelas até a Terceira Forma Normal (3FN)[cite: 2].

---

### Segmento: Loja de Roupas
#### Tabela Original: Vendas [cite: 1]

| VendaID | ClienteNome | ClienteTelefone | FuncionarioNome | ProdutoID | ProdutoNome | Quantidade | Preco | DataVenda |
|---|---|---|---|---|---|---|---|---|
| 1 | João Silva | 1234-5678 | Maria | 101 | Camiseta | 2 | 20.00 | 2024-05-20 |
| 2 | Ana Souza | 2345-6789 | João | 102 | Calça | 1 | 40.00 | 2024-05-21 |
| 3 | Paulo Lima | 3456-7890 | Maria | 101 | Camiseta | 3 | 20.00 | 2024-05-22 |
| 2 | Ana Souza | 2345-6789 | João | 103 | Jaqueta | 1 | 60.00 | 2024-05-21 |

---

### Segmento: Clínica Médica
#### Tabela Original: Consultas [cite: 3]

| ConsultaID | PacienteNome | PacienteTelefone | MedicoNome | Especialidade | DataConsulta | HoraConsulta | Diagnostico | MedicamentoPrescrito |
|---|---|---|---|---|---|---|---|---|
| 1 | Carlos Santos | 4567-8901 | Dr. Lima | Cardiologia | 2024-05-20 | 10:00 | Hipertensão | Atenolol |
| 2 | Marta Oliveira | 5678-9012 | Dra. Souza | Dermatologia | 2024-05-21 | 11:00 | Eczema | Corticóide |
| 3 | João Almeida | 6789-0123 | Dr. Lima | Cardiologia | 2024-05-22 | 09:00 | Arritmia | Beta-bloqueador |
| 4 | Ana Costa | 7890-1234 | Dra. Souza | Dermatologia | 2024-05-23 | 12:00 | Acne | Isotretinoina |

---

### Segmento: Universidade
#### Tabela Original: Matrículas [cite: 4]

| MatriculaID | AlunoNome | AlunoEmail | CursoID | CursoNome | ProfessorNome | Semestre | Nota |
|---|---|---|---|---|---|---|---|
| 1 | João Silva | joao@exemplo.com | 201 | Banco de Dados | Prof. Carlos | 2024-1 | 8.5 |
| 2 | Ana Souza | ana@exemplo.com | 202 | Programação | Prof. Maria | 2024-1 | 9.0 |
| 3 | Paulo Lima | paulo@exemplo.com | 201 | Banco de Dados | Prof. Carlos | 2024-1 | 7.5 |
| 4 | Marta Oliveira | marta@exemplo.com | 203 | Redes | Prof. João | 2024-1 | 8.0 |

---

### Segmento: Biblioteca
#### Tabela Original: Empréstimos [cite: 5]

| EmprestimoID | LivroID | LivroTitulo | Autor | UsuarioID | UsuarioNome | DataEmprestimo | DataDevolucao |
|---|---|---|---|---|---|---|---|---|
| 1 | 101 | "Banco de Dados" | Elmasri | 1001 | João Silva | 2024-05-20 | 2024-06-20 |
| 2 | 102 | "Programação" | Deitel | 1002 | Ana Souza | 2024-05-21 | 2024-06-21 |
| 3 | 103 | "Redes de Computadores" | Tanenbaum | 1001 | João Silva | 2024-05-22 | 2024-06-22 |
| 4 | 104 | "Sistemas Operacionais" | Silberschatz | 1003 | Paulo Lima | 2024-05-23 | 2024-06-23 |

---

### Segmento: Hotelaria
#### Tabela Original: Reservas [cite: 6]

| ReservaID | ClienteNome | ClienteTelefone | QuartoID | QuartoTipo | DataCheckIn | DataCheckOut | FuncionarioNome | PrecoTotal |
|---|---|---|---|---|---|---|---|---|
| 1 | João Silva | 1234-5678 | 301 | Suite | 2024-05-20 | 2024-05-25 | Carlos | 500.00 |
| 2 | Ana Souza | 2345-6789 | 302 | Standard | 2024-05-21 | 2024-05-24 | Maria | 300.00 |
| 3 | Paulo Lima | 3456-7890 | 303 | Suite | 2024-05-22 | 2024-05-26 | João | 600.00 |
| 4 | Marta Oliveira | 4567-8901 | 304 | Deluxe | 2024-05-23 | 2024-05-27 | Ana | 700.00 |

---

### Segmento: Restaurante
#### Tabela Original: Pedidos [cite: 7]

| PedidoID | ClienteNome | ClienteTelefone | PratoID | PratoNome | Quantidade | Preco | DataPedido | GarcomNome |
|---|---|---|---|---|---|---|---|---|
| 1 | João Silva | 1234-5678 | 201 | Pizza | 2 | 40.00 | 2024-05-20 | Carlos |
| 2 | Ana Souza | 2345-6789 | 202 | Hambúrguer | 1 | 20.00 | 2024-05-21 | Maria |
| 3 | Paulo Lima | 3456-7890 | 201 | Pizza | 1 | 40.00 | 2024-05-22 | João |
| 4 | Marta Oliveira | 4567-8901 | 203 | Salada | 3 | 15.00 | 2024-05-23 | Ana |

---

### Segmento: Academia
#### Tabela Original: Inscrições [cite: 8]

| InscricaoID | ClienteNome | ClienteTelefone | PlanoID | PlanoNome | DataInicio | DataFim | FuncionarioNome | Valor |
|---|---|---|---|---|---|---|---|---|
| 1 | João Silva | 1234-5678 | 401 | Mensal | 2024-05-01 | 2024-05-31 | Carlos | 100.00 |
| 2 | Ana Souza | 2345-6789 | 402 | Trimestral | 2024-05-01 | 2024-07-31 | Maria | 250.00 |
| 3 | Paulo Lima | 3456-7890 | 401 | Mensal | 2024-05-01 | 2024-05-31 | João | 100.00 |
| 4 | Marta Oliveira | 4567-8901 | 403 | Anual | 2024-05-01 | 2025-04-30 | Ana | 900.00 |