----- TABELA -----

EMPREGADO (matricula, nome, endereco, salario, supervisor, depto, sexo)
DEPARTAMENTO (coddep, nome (do depto), gerente, dataini)
PROJETO (codproj, nome (do proj), local, depart)
ALOCACAO (matric, codigop, horas)
DEPENDENTE (coddepend, mat, nome (do dependente), sexo, parentesco)
TOTALIZACAO (DepCod, DepNome, Total)
DEPSALARIO (DepCod, DepNome, SomaSal)

----- Exercicios de Triggers -----

01) Suponha que a base da dados Universidade possui uma nova tabela com o total de funcionários
por departamento, com o esquema: Totalizacao (DepCod, DepNome, Total), com o código do
departamento, o nome e a soma dos funcionários de cada departamento. Escreva o trigger para cada
situação : A) Um funcionário novo é contratado; B) Um funcionário é demitido da universidade;

CREATE OR REPLACE FUNCTION atualiza_tabela_totalizacao()
RETURNS TRIGGER
AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN
        UPDATE Totalizacao SET total = total + 1 WHERE DepCod = NEW.depto;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE Totalizacao SET total = total - 1 WHERE DepCod = OLD.depto;
        RETURN OLD;
    END IF;

END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER trg_funcionario_contratado
AFTER INSERT ON EMPREGADO
FOR EACH ROW
EXECUTE FUNCTION atualiza_tabela_totalizacao();

CREATE OR REPLACE TRIGGER trg_funcionario_demitido
AFTER DELETE ON EMPREGADO
FOR EACH ROW
EXECUTE FUNCTION atualiza_tabela_totalizacao();

02) Escreva o trigger que confirma a alocação de um empregado em um projeto;

CREATE OR REPLACE FUNCTION confirma_alocacao_empregado()
RETURNS TRIGGER
AS $$
DECLARE
    nome_empregado VARCHAR;
    nome_novo_proj VARCHAR;
BEGIN

    SELECT nome 
    INTO nome_empregado 
    FROM EMPREGADO 
    WHERE matricula = NEW.matric;

    SELECT nome 
    INTO nome_novo_proj
    FROM PROJETO 
    WHERE codproj = NEW.codigop;

    RAISE NOTICE 'Empregado de nome: %, foi alocado para o projeto %', nome_empregado, nome_novo_proj;

    RETURN NEW;

END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER trg_alocacao_empregado_confirma
AFTER UPDATE OR INSERT ON ALOCACAO
FOR EACH ROW
EXECUTE FUNCTION confirma_alocacao_empregado();


03) Crie o trigger que verifica se um funcionário foi relocado para um projeto com 10 ou mais pessoas
participantes dele. Caso o projeto tenha mais de 10 pessoas, a ação deve ser cancelada e informada.
Caso contrário, a ação é confirmada e informada ao usuário;

CREATE OR REPLACE FUNCTION verifica_limite_projeto()
RETURNS TRIGGER
AS $$
DECLARE
    quantidade_pessoas_novo_projeto INT;
BEGIN

    SELECT COUNT(codigop) INTO quantidade_pessoas_novo_projeto 
    FROM ALOCACAO 
    WHERE codigop = NEW.codigop;

    IF quantidade_pessoas_novo_projeto >= 10 THEN
        RAISE EXCEPTION 'Quantidade de pessoas alocadas no projeto maior do que 10';
    END IF;

    RETURN NEW;
END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER trig_verifica_limite_projeto
BEFORE UPDATE OF codigop ON ALOCACAO
FOR EACH ROW
EXECUTE FUNCTION verifica_limite_projeto();

04) Considerando que os departamentos de código 9, 10 e 11 já estão com limite máximo de funcionários (20), 
escreva o trigger que cancela qualquer tentativa de alocação de funcionários pra qualquer um desses departamentos;

CREATE OR REPLACE FUNCTION impedir_alocacao_departamento_lotado()
RETURNS TRIGGER
AS $$
DECLARE 
    codigo_departamento INT;
BEGIN
    SELECT depart INTO codigo_departamento FROM PROJETO WHERE codproj = NEW.codigop;

    IF codigo_departamento IN(9, 10, 11) THEN
        RAISE EXCEPTION 'Departamento 9, 10 e 11 com capacidade máxima' USING HINT = 'Evite os departamentos 9, 10, e 11, pois estão com capacidade máxima';
    END IF;

    RETURN NEW;

END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER valida_departamentos
BEFORE UPDATE OR INSERT ON ALOCACAO
FOR EACH ROW
EXECUTE FUNCTION impedir_alocacao_departamento_lotado();

05) Sabendo que o proprietário de uma empresa não pode ser demitido, escreva um trigger usando WHEN
que avise caso o registro sendo deletado seja o 22334455, que é o CPF do proprietário;

CREATE OR REPLACE FUNCTION verifica_se_demitido_eh_proprietario()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Proprietario com matricula % não pode ser demitido', OLD.matricula;

    RETURN OLD;
END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER trg_TestaProprietario
BEFORE DELETE ON EMPREGADO
FOR EACH ROW
WHEN(OLD.matricula = '22334455')
EXECUTE FUNCTION verifica_se_demitido_eh_proprietario();

06) Considere que a base de dados Universidade tem uma tabela DepSalario (DepCod, DepNome, SomaSal). 
Escreva o trigger de instrução que atualiza esta tabela sempre que a soma salarial de um 
departamento sofrer qualquer tipo de alteração;

CREATE OR REPLACE FUNCTION trg_atualiza_dep_salario_statement()
RETURNS TRIGGER AS $$
BEGIN
    TRUNCATE TABLE DepSalario;

    INSERT INTO DepSalario (DepCod, DepNome, SomaSal)
    SELECT d.coddep, d.nome, COALESCE(SUM(e.salario), 0)
    FROM
        DEPARTAMENTO d
    LEFT JOIN
        EMPREGADO e ON d.coddep = e.depto
    GROUP BY
        d.coddep, d.nome;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_AtualizaDepSalario
AFTER INSERT OR UPDATE OF salario OR DELETE ON EMPREGADO
FOR EACH STATEMENT
EXECUTE FUNCTION trg_atualiza_dep_salario_statement();

07) Crie o trigger que imprime na tela uma mensagem informando uma mudança de endereço. É
preciso emitir um desses três tipos de mensagens: 
    A) O empregado morava numa rua e agora mora numa
    avenida; 
    B) O empregado morava numa avenida e agora mora
    numa rua; 
    C) O empregado passou a morar num endereço que
    não é rua e nem avenida; 
Para a criação desse trigger, renomeie NEW e OLD
como preferir;

CREATE OR REPLACE FUNCTION trg_alerta_mudanca_endereco()
RETURNS TRIGGER AS $$
DECLARE
    Antigo_endereco ALIAS FOR OLD.endereco;
    Antigo_nome ALIAS FOR OLD.nome;
    Novo_endereco ALIAS FOR NEW.endereco;

    morava_rua BOOLEAN;
    morava_avenida BOOLEAN;
    mudou_para_rua BOOLEAN;
    mudou_para_avenida BOOLEAN;
BEGIN
    morava_rua        := Antigo_endereco ILIKE 'Rua %';
    morava_avenida    := Antigo_endereco ILIKE 'Avenida %' OR Antigo_endereco ILIKE 'Av.%';
    mudou_para_rua    := Novo_endereco ILIKE 'Rua %';
    mudou_para_avenida:= Novo_endereco ILIKE 'Avenida %' OR Novo_endereco ILIKE 'Av.%';

    IF morava_rua AND mudou_para_avenida THEN
        RAISE NOTICE 'A) O empregado % morava numa rua e agora mora numa avenida. Novo: %', Antigo_nome, Novo_endereco;
    ELSIF morava_avenida AND mudou_para_rua THEN
        RAISE NOTICE 'B) O empregado % morava numa avenida e agora mora numa rua. Novo: %', Antigo_nome, Novo_endereco;
    ELSE
        RAISE NOTICE 'C) O empregado % passou a morar num endereço que não é rua e nem avenida (ou a transição foi diferente). Novo: %', Antigo_nome, Novo_endereco;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_MudancaEndereco
AFTER UPDATE OF endereco ON EMPREGADO
FOR EACH ROW
WHEN (OLD.endereco IS DISTINCT FROM NEW.endereco)
EXECUTE FUNCTION trg_alerta_mudanca_endereco();

08) Escreva o trigger que trata do atributo salário. Caso seja uma inserção, o valor nunca pode ser
inferior a R$1000.00. Caso seja uma atualização, então o valor nunca pode ser inferior a R$1200.00.
Em ambas situações, se o valor for menor do que o limite exposto, deve ser emitida uma mensagem
informando da proibição da ação, e todo o processo deve ser desfeito;

CREATE OR REPLACE FUNCTION trg_verifica_limite_salarial()
RETURNS TRIGGER AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN
        IF NEW.salario < 1000 THEN
            RAISE EXCEPTION 'Salario não pode ser inferior a R$1000 no método de inserção.'
        END IF;

    ELSIF TG_OP = 'UPDATE' THEN
          IF NEW.salario < 1200 THEN
            RAISE EXCEPTION 'Salario não pode ser inferior a R$1200 no método de atualização.'
        END IF;
    END IF;

    RETURN NEW;
    
END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER trg_LimiteSalarial
BEFORE INSERT OR UPDATE OF salario ON EMPREGADO
FOR EACH ROW
EXECUTE FUNCTION trg_verifica_limite_salarial();

09) Crie um trigger que verifica se o salário de um funcionário é maior do que o salário do chefe
imediato dele. Se for, avisar ao usuário e desfazer tudo, caso não seja, informar que a operação
aconteceu com sucesso;

CREATE OR REPLACE FUNCTION verifica_se_salario_funcionario_menor_chefe()
RETURNS TRIGGER
AS $$
DECLARE 
    salario_chefe DECIMAL(10,2);
BEGIN

    SELECT salario INTO salario_chefe FROM EMPREGADO WHERE matricula = NEW.supervisor;

    IF salario_chefe IS NULL THEN
        RAISE EXCEPTION 'Supervisor nulo'
    END IF;

    IF NEW.salario > salario_chefe THEN
        RAISE EXCEPTION 'Salario de funcionario não poder ser maior do que o salario do seu supervisor' USING HINT = 'Salario do funcionario deve ser menor que o do supervisor';
    ELSE
        RAISE NOTICE 'A opereção ocorreu com sucesso.'
    END IF;

    RETURN NEW;

END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER tgr_verifica_se_salario_funcionario_menor_chefe
BEFORE INSERT OR UPDATE ON EMPREGADO 
FOR EACH ROW
EXECUTE FUNCTION verifica_se_salario_funcionario_menor_chefe();

----------------------------------------------------------------------------------------------------

--- Tabela ---

Especialidade(Reg$i$stro, NomeEsp, Preço)
Funcionário(Matricula, Nome, Endereço, Salário, TempoDeCasa)
Médico(MatriMed, Crm, RegEsp, AnosExp)
    -> MatriMed referencia Funcionário
    -> RegEsp referencia Especialidade
Administrativo(MatriAdm, Função, CgHorária)
    -> MatriAdm referencia Funcionário
PlanoDeSaude(Numera, Descrição, Cobertura)
Paciente(Cpf, Nome, Endereço, Telefone, Dependente, NumPS)
    -> NumPS referencia PlanoDeSaude
Consulta(Id, AdmMat, MedMat, CpfPaciente, Data, Hora, Tipo)
    -> AdmMat referencia Administrativo
    -> MedMat referencia Médico
    -> CpfPaciente referencia Paciente
Totalização(AMat, MMat, SomaValor)
    -> AMat referencia Administrativo
    -> MMat referencia Médico
BkpTot(MAt, SomaValor, DtDemi)
BkpCons(Id, AdmMat, MedMat, CpfPaciente, Data, Hora, Tipo, DtDel)

-> Nessas duas últimas tabelas, o campo **DtDemi** é a data da demissão do funcionário, e **DtDel** é a 
    data em que uma consulta foi deletada. Esses campos devem ser coletados com a função `now()`;
-> Na tabela **BkpTot**, **SomaValor** é o somatório de quanto em dinheiro aquele funcionário já conseguiu para a empresa;

---

1) Crie o trigger que é disparado quando um médico é deletado da base de dados. As informações desse 
médico devem ser passadas para a tabela BkpTot juntamente com a data de demissão (DtDemi).

CREATE OR REPLACE FUNCTION fn_backup_medico()
RETURNS TRIGGER AS $$
DECLARE
    somaValor Decimal(10,2);
BEGIN

    SELECT COALESCE(SUM(SomaValor),0) INTO somaValor FROM TOTALIZACAO WHERE MMat = OLD.MatriMed;

    INSERT INTO BkpTot (MAt, SomaValor, DtDemi)
    VALUES (OLD.MatriMed, somaValor, NOW());

    RETURN OLD;

END;
$$ Language plpgsql;


CREATE OR REPLACE TRIGGER tgr_deleta_medico
AFTER DELETE ON MEDICO
FOR EACH ROW
EXECUTE FUNCTION fn_backup_medico()

2) Faça o Trigger que é disparado quando uma "consulta é desmarcada" da clínica. Todos os dados da consulta 
devem passar para a tabela BkpCons incluindo a data em que ela foi deletada. O trigger ainda deve mostrar 
uma mensagem informando que:

A) A consulta foi cancelada e ela seria feita pelo médico de nome **XXX**, marcada pelo funcionário de nome **YYY**, na data de **ZZZ**.
B) **XXX**, **YYY** e **ZZZ** são respectivamente o nome do médico, o nome do funcionário do administrativo e a data em que a consulta seria feita;

CREATE OR REPLACE FUNCTION fn_backup_consulta_desmarcada()
RETURNS TRIGGER AS $$
DECLARE
    nome_medico TEXT;
    nome_funcionario TEXT;
    id_BkpCons INT;
BEGIN

    SELECT f.Nome
    INTO nome_medico
    FROM MEDICO m
    INNER JOIN FUNCIONARIO f ON m.MatriMed = f.Matricula
    WHERE m.MatriMed = OLD.MedMat;

    SELECT f.Nome
    INTO nome_funcionario
    FROM ADMINISTRATIVO a
    INNER JOIN FUNCIONARIO f ON a.MatriAdm = f.Matricula
    WHERE a.MatriAdm = OLD.AdmMat;

    SELECT COALESCE(MAX(id), 0) + 1
    INTO id_BkpCons
    FROM BkpCons;

    INSERT INTO BkpCons(Id, AdmMat, MedMat, CpfPaciente, Data, Hora, Tipo, DtDel)
    VALUES(id_BkpCons, OLD.AdmMat, OLD.MedMat, OLD.CpfPaciente, OLD.Data, OLD.Hora, OLD.Tipo, NOW());

    RAISE NOTICE 'A consulta foi cancelada e ela seria feita pelo médico de nome %, marcada pelo funcionário de nome %, na data de %.', nome_medico,
    nome_funcionario, OLD.Data;

    RETURN OLD;
END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER tg_consulta_eh_desmarcada
AFTER DELETE ON CONSULTA
FOR EACH ROW
EXECUTE FUNCTION fn_backup_consulta_desmarcada();