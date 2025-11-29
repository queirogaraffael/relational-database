----- TABELA -----

EMPREGADO (matricula, nome, endereco, salario, supervisor, depto, sexo)
DEPARTAMENTO (coddep, nome (do depto), gerente, dataini)
PROJETO (codproj, nome (do proj), local, depart, orcamento)
ALOCACAO (matric, codigop, horas)
DEPENDENTE (coddepend, mat, nome (do dependente), sexo, parentesco)
TOTALIZACAO (DepCod, DepNome, Total)
DEPSALARIO (DepCod, DepNome, SomaSal)
TotProj(Codicoproj, Nomeproj, QtdNoProj, DtProj)
EmpBkP (bkp_id, matricula_antiga, nome, endereco, salario, supervisor, depto, sexo, dependentes_qtd, projetos_qtd, data_delecao)

----- Exercicios de Funções e Triggers -----

01) Crie a função que qualifica um projeto pelo seu orçamento. Se for menos que R$2000.00, o projeto é
de ‘baixo investimento’, se for menor que R$5000.00, é de ‘investimento mediano’, se for abaixo de
R$15000.00, é de ‘alto investimento’, e acima disso, deve ser ‘auto-sustentável’;

CREATE OR REPLACE FUNCTION qualifica_projeto(p_orcamento NUMERIC)
RETURNS VARCHAR AS $$
BEGIN
    IF p_orcamento IS NULL OR p_orcamento < 2000.00 THEN
        RETURN 'Projeto de baixo investimento';
    ELSIF orcamento < 5000 THEN 
        RETURN 'Projeto de investimento mediano';
    ELSIF orcamento < 15000 THEN
        RETURN 'Projeto de alto investimento';
    ELSE
        RETURN 'Projeto auto-sustentável';
    END IF;
END;
$$ LANGUAGE plpgsql;

02) Crie a função que recebe a matrícula de um empregado e retorna o nome do supervisor dele. Em
seguida, crie a consulta que retorna a matrícula do empregado, o nome dele e nome do supervisor,
mostrando também o nome do departamento em que ele trabalha;

CREATE OR REPLACE FUNCTION nome_supervisor(IN mat_sup INT, OUT nome_sup TEXT)
RETURNS TEXT AS $$
BEGIN
    SELECT nome 
    INTO nome_sup
    FROM EMPREGADO
    WHERE matricula = mat_sup;
END;
$$ LANGUAGE plpgsql;

SELECT
    e.matricula,
    e.nome AS nome_empregado,
    nome_supervisor(e.supervisor) AS nome_supervisor,
    d.nome AS nome_departamento
FROM
    EMPREGADO e
JOIN
    DEPARTAMENTO d ON e.depto = d.coddep;

03) Escreva a consulta que mostra a matrícula do empregado, o nome, o nome do departamento em
que ele trabalha e também quantas pessoas estão alocadas naquele departamento, mas somente dos
empregados que têm dependentes. A quantidade de pessoas deve ser exibida via função, e recebe apenas
o código do departamento (calcula a quantidade de pessoas que têm ou não dependentes);

CREATE OR REPLACE FUNCTION qtd_empregados_por_depto(IN codigoD INT, OUT qtd INT)
AS $$
BEGIN
    SELECT COUNT(matricula) 
    INTO qtd
    FROM EMPREGADO
    WHERE depto = codigoD;
END;
$$ LANGUAGE plpgsql;

SELECT
    e.matricula,
    e.nome AS nome_empregado,
    d.nome AS nome_departamento,
    qtd_empregados_por_depto(e.depto) AS total_empregados_no_depto
FROM
    EMPREGADO e
JOIN
    DEPARTAMENTO d ON e.depto = d.coddep
WHERE
    EXISTS (SELECT 1 FROM DEPENDENTE dep WHERE dep.mat = e.matricula);

04) Crie a consulta que retorna as matrículas e nomes de todos os funcionários, exceto os de
Fisioterapia, e que ainda deve mostrar o nome do departamento do funcionário e um campo adicional
que mostra se a pessoa ‘possui’ ou ‘não possui’ dependentes (que deve ser calculado via função);

CREATE OR REPLACE FUNCTION status_dependentes(p_matricula INT)
RETURNS VARCHAR AS $$
DECLARE
    tem_dependentes BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM DEPENDENTE WHERE mat = p_matricula) INTO tem_dependentes;

    IF tem_dependentes THEN
        RETURN 'possui';
    ELSE
        RETURN 'não possui';
    END IF;
END;
$$ LANGUAGE plpgsql;

SELECT
    e.matricula,
    e.nome AS nome_empregado,
    d.nome AS nome_departamento,
    status_dependentes(e.matricula) AS possui_dependentes
FROM
    EMPREGADO e
JOIN
    DEPARTAMENTO d ON e.depto = d.coddep
WHERE
    d.nome <> 'Fisioterapia';

05) Escreva função que recebe um código de um projeto e retorna o nome do projeto e quantas pessoas 
estão trabalhando naquele projeto. Então crie uma consulta que mostre o nome do empregado, o código do 
projeto em que ele trabalha e ainda mostre (via função) o nome do projeto e quantas pessoas trabalham nele;

CREATE OR REPLACE FUNCTION informacoes_projeto(codigo_projeto INT)
RETURNS TABLE(nome_projeto VARCHAR, 
                num_pessoas_projeto INT) 
AS $$
BEGIN
    RETURN QUERY
    SELECT p.nome, COUNT(a.codigop) 
    FROM ALOCACAO a
    LEFT JOIN PROJETO p ON a.codigop = p.codproj
    WHERE a.codigop = codigo_projeto
    GROUP BY p.nome;
END;
$$ Language plpgsql;

SELECT 
    e.nome, 
    a.codigop, 
    t.*
FROM EMPREGADO e
JOIN ALOCACAO a ON e.matricula = a.matric
CROSS JOIN LATERAL 
    informacoes_projeto(a.codigop) AS t;

06) Crie a função que recebe a matrícula de um empregado e retorna a quantidade de dependentes
que ele tem, a quantidade de projetos em que ele trabalha e a média salarial das pessoas do mesmo
departamento que ele. Depois crie a consulta que mostra o nome do empregado e o seu departamento,
e mostra todas os dados da função criada;

CREATE OR REPLACE FUNCTION info_empregado_completa(matricula_empregado INT)
RETURNS TABLE (
    qtd_dependentes INT,
    qtd_projetos INT,
    media_salario_depto DECIMAL(10, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(coddepend) FROM DEPENDENTE WHERE mat = matricula_empregado),
        (SELECT COUNT(matric) FROM ALOCACAO WHERE matric = matricula_empregado),
        (SELECT AVG(salario) FROM EMPREGADO WHERE depto IN (SELECT dpto FROM EMPREGADO WHERE matricula = matricula_empregado));
END;
$$ LANGUAGE plpgsql;

SELECT
    e.nome AS nome_empregado,
    d.nome AS nome_departamento,
    t.*
FROM
    EMPREGADO e
JOIN
    DEPARTAMENTO d ON e.depto = d.coddep
CROSS JOIN LATERAL
    info_empregado_completa(e.matricula) AS t;

07) Escreva a função que recebe a matrícula de um empregado e o código do departamento para onde ele
vai ser relocado. A função deve transferir o empregado pro novo setor, e ainda deve contar com quantos
empregados o novo setor ficou para retornar este valor. Além disso, a função emite uma mensagem informando
com quantos funcionários o setor antigo ficou com o formato: “O funcionário % saiu do departamento %,
que passou a ter % funcionários e foi lotado no setor % que agora tem % funcionários”, e os campos a serem
exibidos nessa ordem são: nome do funcionário, nome do departamento antigo, quantidade de funcionários do
dep antigo, nome do novo dep, e quantidade de funcionários do novo dep;

CREATE OR REPLACE FUNCTION reloca_empregado_e_conta(IN p_matricula INT, IN p_cod_novo_depto INT)
RETURNS INT AS $$
DECLARE
    v_nome_func VARCHAR(150);
    v_cod_antigo_depto INT;
    v_nome_antigo_depto VARCHAR(100);
    v_nome_novo_depto VARCHAR(100);
    v_qtd_antigo INT;
    v_qtd_novo INT;
BEGIN
    SELECT nome, depto 
    INTO v_nome_func, v_cod_antigo_depto
    FROM EMPREGADO
    WHERE matricula = p_matricula;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Empregado de matrícula % não encontrado.', p_matricula;
    END IF;

    SELECT nome INTO v_nome_antigo_depto FROM DEPARTAMENTO WHERE coddep = v_cod_antigo_depto;

    SELECT nome INTO v_nome_novo_depto FROM DEPARTAMENTO coddep = p_cod_novo_depto;

    IF v_nome_novo_depto IS NULL THEN
        RAISE EXCEPTION 'Departamento de código % não encontrado.', p_cod_novo_depto;
    END IF;

    UPDATE EMPREGADO
    SET depto = p_cod_novo_depto
    WHERE matricula = p_matricula;

    SELECT COUNT(*) INTO v_qtd_antigo FROM EMPREGADO WHERE depto = v_cod_antigo_depto;

    SELECT COUNT(*) INTO v_qtd_novo FROM EMPREGADO WHERE depto = p_cod_novo_depto;

    RAISE NOTICE 'O funcionário % saiu do departamento %, que passou a ter % funcionários e foi lotado no setor % que agora tem % funcionários',
                  v_nome_func, v_nome_antigo_depto, v_qtd_antigo, v_nome_novo_depto, v_qtd_novo;

    RETURN v_qtd_novo;

END;
$$ LANGUAGE plpgsql;

08) Crie uma nova função add_cargo3 que recebe a matrícula e o salário de um funcionário e retorna o
cargo exercido. Todos os parâmetros de entrada e saída devem possuir apenas seus tipos definidos (use
OUT pro parâmetro de saída e crie ALIAS para ao menos 1 deles). A função deve emitir mensagens que
mostram em qual ponto do IF o fluxo entrou, mostrando ainda qual o nome e salário do
funcionário, e dizendo qual o cargo dele, e ainda deve retornar o cargo exercido. Se o salário for
menor ou igual a 1500, é Auxiliar. Se for menor ou igual a 2500, é Assistente. Se for menor ou igual a
3500 é Titular. Caso seja maior do que isso, o processamento deve ser interrompido e alertado;

CREATE OR REPLACE FUNCTION add_cargo3(IN mat_func INT, IN salario_func DECIMAL(10,2), OUT cargo_exercido VARCHAR) 
AS $$
DECLARE
    v_salario ALIAS FOR salario_func;
    v_nome_func VARCHAR(150);
BEGIN
    SELECT nome INTO v_nome_func FROM EMPREGADO WHERE matricula = mat_func;

    IF v_salario <= 1500.00 THEN
        cargo_exercido := 'Auxiliar';
        RAISE NOTICE 'IF (Auxiliar): Salário de % (R$%) <= 1500.00. Cargo: %', v_nome_func, v_salario, cargo_exercido;
    ELSIF v_salario <= 2500.00 THEN
        cargo_exercido := 'Assistente';
        RAISE NOTICE 'ELSIF (Assistente): Salário de % (R$%) <= 2500.00. Cargo: %', v_nome_func, v_salario, cargo_exercido;
    ELSIF v_salario <= 3500.00 THEN
        cargo_exercido := 'Titular';
        RAISE NOTICE 'ELSIF (Titular): Salário de % (R$%) <= 3500.00. Cargo: %', v_nome_func, v_salario, cargo_exercido;
    ELSE
        RAISE EXCEPTION 'Processamento interrompido: O salário de % (R$%) excede o limite de R$3500.00.', v_nome_func, v_salario;
    END IF;
END;
$$ LANGUAGE plpgsql;

09) Crie a função que recebe um código de um projeto e um código de departamento para o qual o projeto será
transferido. A função só declara os tipos dos objetos e trabalha usando apelidos pra eles. Caso o departamento de
destino tenha 10 projetos ou menos, uma mensagem é emitida informando o nome do departamento e com quantos
projetos ele ficou depois da nova adição. Nesses casos, a função retorna ‘Poucos projetos’. Caso o departamento de
destino tenha 50 projetos ou menos, é emitida a mensagem informando o nome do departamento, a quantidade de
projetos que tem e reforçando que o departamento tem projetos demais. A função deve retornar ‘Muitos projetos’,
nesse caso. Caso o departamento ultrapasse os 50 projetos, um alerta deve ser emitido informando o nome do
departamento, a quantidade de projetos que ele tem, e que a transferência não pode ser feita por exceder o limite
máximo permitido e a execução deve ser interrompida;

CREATE OR REPLACE FUNCTION transfere_projeto_com_limite(
    proj_cod INT,
    depto_cod INT
)
RETURNS TEXT AS $$
DECLARE
    cod_proj ALIAS FOR proj_cod;
    cod_depto ALIAS FOR depto_cod;
    qtd_projetos INT;
    nome_depto VARCHAR(100);
BEGIN
    UPDATE PROJETO SET depart = cod_depto WHERE codproj = cod_proj;

    SELECT nome, COUNT(codproj) 
    INTO nome_depto, qtd_projetos
    FROM DEPARTAMENTO d
    LEFT JOIN PROJETO p ON d.coddep = p.depart
    WHERE d.coddep = cod_depto
    GROUP BY d.nome;

    IF qtd_projetos > 50 THEN
        RAISE EXCEPTION 'Transferência cancelada: O departamento % (cod: %) possui % projetos, excedendo o limite máximo permitido de 50.', nome_depto, cod_depto, qtd_projetos;
    ELSIF qtd_projetos <= 10 THEN
        RAISE NOTICE 'Departamento % ficou com % projetos.', nome_depto, qtd_projetos;
        RETURN 'Poucos projetos';
    ELSIF qtd_projetos <= 50 THEN
        RAISE NOTICE 'Departamento % tem % projetos, reforçando que o departamento tem projetos demais.', nome_depto, qtd_projetos;
        RETURN 'Muitos projetos';
    END IF;

    RETURN 'Erro inesperado';
END;
$$ LANGUAGE plpgsql;

10) Reescreva as funções das questões 09 e 10, mas agora adicione HINTS que orientem o usuário sobre
como devem proceder para que não sejam geradas exceções nessas suas funções;

CREATE OR REPLACE FUNCTION add_cargo3_v2(mat_func INT, salario_func DECIMAL(10,2), OUT cargo_exercido VARCHAR) 
AS $$
DECLARE
    v_salario ALIAS FOR salario_func;
    v_nome_func VARCHAR(150);
BEGIN
    SELECT nome INTO v_nome_func FROM EMPREGADO WHERE matricula = mat_func;

    IF v_salario <= 1500.00 THEN
        cargo_exercido := 'Auxiliar';
    ELSIF v_salario <= 2500.00 THEN
        cargo_exercido := 'Assistente';
    ELSIF v_salario <= 3500.00 THEN
        cargo_exercido := 'Titular';
    ELSE
        RAISE EXCEPTION 'Processamento interrompido: O salário de % (R$%) excede o limite de R$3500.00.', v_nome_func, v_salario
        USING HINT = 'Para evitar esta exceção, ajuste o salário para um valor igual ou inferior a R$3500.00 (Titular) antes de chamar a função.';
    END IF;

    RAISE NOTICE 'Novo cargo de %: %', v_nome_func, cargo_exercido;
END;
$$ LANGUAGE plpgsql;

--- 

CREATE OR REPLACE FUNCTION transfere_projeto_com_limite_v2(
    proj_cod INT,
    depto_cod INT
)
RETURNS TEXT AS $$
DECLARE
    cod_proj ALIAS FOR proj_cod;
    cod_depto ALIAS FOR depto_cod;
    qtd_projetos INT;
    nome_depto VARCHAR(100);
BEGIN
    UPDATE PROJETO SET depart = cod_depto WHERE codproj = cod_proj;

    SELECT nome, COUNT(codproj) INTO nome_depto, qtd_projetos
    FROM DEPARTAMENTO d
    LEFT JOIN PROJETO p ON d.coddep = p.depart
    WHERE d.coddep = cod_depto
    GROUP BY d.nome;

    IF qtd_projetos > 50 THEN
        RAISE EXCEPTION 'Transferência cancelada: O departamento % (cod: %) possui % projetos, excedendo o limite máximo permitido de 50.', nome_depto, cod_depto, qtd_projetos
        USING HINT = 'O limite máximo de projetos por departamento é 50. Escolha outro departamento de destino com menos projetos.';
    ELSIF qtd_projetos <= 10 THEN
        RAISE NOTICE 'Departamento % ficou com % projetos (Poucos projetos).', nome_depto, qtd_projetos;
        RETURN 'Poucos projetos';
    ELSE
        RAISE NOTICE 'Departamento % tem % projetos (Muitos projetos).', nome_depto, qtd_projetos;
        RETURN 'Muitos projetos';
    END IF;
END;
$$ LANGUAGE plpgsql;

11) Escreva a função que salva num record os dados dos funcionários do departamento de Sistemas que
que possuem mais de um filho. A função deve enviar uma mensagem com o nome, salário e endereço do
primeiro funcionário encontrado. Caso o salário seja maior ou igual a R$3000.00, a função retorna que o
funcionário é efetivo, caso contrário, retorna que ele é temporário;

CREATE OR REPLACE FUNCTION fn_funcionarios_informacoes()
RETURNS VARCHAR AS $$
DECLARE
    dados_funcionario RECORD;
BEGIN
    SELECT e.nome, e.salario, e.endereco
    INTO dados_funcionario
    FROM EMPREGADO e
    INNER JOIN DEPARTAMENTO depart ON e.depto = depart.coddep
    WHERE (SELECT COUNT(*) FROM DEPENDENTE d WHERE d.mat = e.matricula) > 2
        AND depart.nome = 'Sistemas'
    ORDER BY e.nome
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN 'Nenhum funcionário encontrado';
    END IF;

    RAISE NOTICE 'Nome: %, Salário: %, Endereco: %.', dados_funcionario.nome, dados_funcionario.salario, dados_funcionario.endereco;

    IF dados_funcionario.salario >= 3000 THEN
        RETURN 'EFETIVO';
    ELSE
        RETURN 'Temporário';
    END IF;

END;
$$ Language plpgsql;

12) Escreva a função que retorna um record com os dados do primeiro funcionário localizado que esteja
em projetos do departamento de Matemática e que receba mais de 2000.00. Ainda emite uma mensagem
com o nome do departamento do funcionário;

CREATE OR REPLACE FUNCTION fn_informacoes_funcionario()
RETURNS SETOF EMPREGADO AS $$
DECLARE
    r_func EMPREGADO;
BEGIN

    SELECT e.*
    INTO r_func
    FROM EMPREGADO e
    INNER JOIN ALOCACAO a ON e.matricula = a.matric
    INNER JOIN PROJETO p ON a.codigop = p.codproj
    INNER JOIN DEPARTAMENTO d ON p.depto = d.coddep
    WHERE d.nome = 'Matemática'
        AND e.salario > 2000
    ORDER BY e.nome
    LIMIT 1;

    RAISE NOTICE 'Departamento do funcionário: Matemática';

    RETURN NEXT r_func;
    RETURN;
END;
$$ Language plpgsql;

13) Escreva a função que seleciona todos os funcionários que participam de projetos. Caso o
funcionário esteja em 1 projeto, ele deve receber 1% de aumento no salário, caso participe de 2 ou 3, ele
recebe 2% de aumento de salário. Caso ele esteja em 4 ou mais projetos, o funcionário recebe 3% de
aumento. A função ainda deve exibir uma mensagem mostrando o nome do funcionário, a matrícula e o
salário anterior dele, e depois de conceder os aumentos, mostrar o nome do funcionário, o
departamento em que ele trabalha e o novo salário;

CREATE OR REPLACE FUNCTION aplica_aumento_por_projeto()
RETURNS VOID AS $$
DECLARE
    r_func RECORD;
    qtd_projetos INT;
    percentual_aumento NUMERIC(4, 2);
    novo_salario NUMERIC(10, 2);
BEGIN
    FOR r_func IN
        SELECT
            e.matricula, e.nome, e.salario AS salario_antigo, e.depto, COUNT(a.codigop) AS num_projetos
        FROM
            EMPREGADO e
        JOIN
            ALOCACAO a ON e.matricula = a.matric
        GROUP BY
            e.matricula, e.nome, e.salario, e.depto
        HAVING
            COUNT(a.codigop) > 0
    LOOP
        qtd_projetos := r_func.num_projetos;
        percentual_aumento := 0.00;

        IF qtd_projetos = 1 THEN
            percentual_aumento := 0.01;
        ELSIF qtd_projetos >= 2 AND qtd_projetos <= 3 THEN
            percentual_aumento := 0.02;
        ELSIF qtd_projetos >= 4 THEN
            percentual_aumento := 0.03;
        END IF;

        IF percentual_aumento > 0 THEN
            novo_salario := r_func.salario_antigo * (1 + percentual_aumento);

            RAISE NOTICE 'PRÉ-AUMENTO: Empregado: %, Matrícula: %, Salário Anterior: R$%',
                         r_func.nome, r_func.matricula, r_func.salario_antigo;

            UPDATE EMPREGADO
            SET salario = novo_salario
            WHERE matricula = r_func.matricula;

            SELECT nome INTO r_func.depto
            FROM DEPARTAMENTO
            WHERE coddep = r_func.depto;

            RAISE NOTICE 'PÓS-AUMENTO: Empregado: %, Departamento: %, Novo Salário: R$%',
                         r_func.nome, r_func.depto, novo_salario;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

14) Crie o trigger que é disparado sempre que um empregado é deletado da base de dados. Esse
trigger deve salvar na tabela EmpBkp todos os dados do empregado (presentes na tabela
empregado), e ainda deve remover os dependentes, caso ele os tenha, e também desalocá-lo dos projetos
dos quais ele participava, mas antes disso, ainda deve ser salvo em EmpBkp quantos dependentes ele
possuía e de quantos projetos ele participava, além de incluir lá também a data em que a deleção foi
executada no sistema;

CREATE OR REPLACE FUNCTION fn_empregado_deletado()
RETURNS TRIGGER AS $$
DECLARE
    bkp_id INT;
    dependentes_qtd INT;
    projetos_qtd INT;
BEGIN

    SELECT COUNT(*)
    INTO dependentes_qtd
    FROM DEPENDENTE
    WHERE mat = OLD.matricula;

    SELECT COUNT(*)
    INTO projetos_qtd
    FROM ALOCACAO
    WHERE matric = OLD.matricula;

    SELECT COALESCE(MAX(bkp_id),0) + 1
    INTO bkp_id
    FROM EmpBkP;

    INSERT INTO EmpBkP(bkp_id, matricula_antiga, nome, endereco, salario, supervisor, depto, sexo, dependentes_qtd, projetos_qtd, data_delecao)
    VALUES(bkp_id, OLD.matricula, OLD.nome, OLD.endereco, OLD.salario, OLD.supervisor, OLD.depto, OLD.sexo, dependentes_qtd, projetos_qtd, NOW());

    DELETE FROM DEPENDENTE
    WHERE mat = OLD.matricula;

    DELETE FROM ALOCACAO
    WHERE matric = OLD.matricula;

    RETURN OLD;

END;
$$ Language plpgsql;

CREATE OR REPLACE TRIGGER tg_empregado_deletado
BEFORE DELETE ON EMPREGADO
FOR EACH ROW
EXECUTE FUNCTION fn_empregado_deletado();

15) Crie o trigger que é disparado sempre que alguma atualização é feita na tabela Alocacao.
Quando essas ações acontecem, a tabela TotProj é atualizada. A tabela TotProj é uma totalização dos
projetos da empresa, mostrando o código do projeto, o nome do projeto, a quantidade de pessoas
trabalhando naquele projeto e a data em que a última atualização foi feita: TotProj (Cproj, Nproj,
QtdProj, DtProj). O trigger deve mostrar qual o evento que disparou o trigger, o nome do projeto
que perdeu um participante, o nome do projeto que ganhou mais um participante e com quantas pessoas
cada projeto ficou;

CREATE OR REPLACE FUNCTION trg_atualiza_totproj()
RETURNS TRIGGER AS $$
DECLARE
    nome_proj_antigo VARCHAR(100);
    nome_proj_novo VARCHAR(100);
    qtd_proj_antigo INT;
    qtd_proj_novo INT;
    evento TEXT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        evento := 'INSERT (Nova Alocação)';

        SELECT COUNT(matric) INTO qtd_proj_novo FROM ALOCACAO WHERE codigop = NEW.codigop;
        SELECT nome INTO nome_proj_novo FROM PROJETO WHERE codproj = NEW.codigop;

        INSERT INTO TotProj (Cproj, Nproj, QtdProj, DtProj)
        VALUES (NEW.codigop, nome_proj_novo, qtd_proj_novo, CURRENT_TIMESTAMP)
        ON CONFLICT (Cproj) DO UPDATE SET
            QtdProj = EXCLUDED.QtdProj,
            DtProj = EXCLUDED.DtProj;

        RAISE NOTICE 'Evento: % | Projeto % (cód: %) ganhou 1 participante. Total atual: %', evento, nome_proj_novo, NEW.codigop, qtd_proj_novo;

    ELSIF TG_OP = 'DELETE' THEN
        evento := 'DELETE (Desalocação)';

        SELECT COUNT(matric) INTO qtd_proj_antigo FROM ALOCACAO WHERE codigop = OLD.codigop;
        SELECT nome INTO nome_proj_antigo FROM PROJETO WHERE codproj = OLD.codigop;

        UPDATE TotProj SET QtdProj = qtd_proj_antigo, DtProj = CURRENT_TIMESTAMP
        WHERE Cproj = OLD.codigop;

        RAISE NOTICE 'Evento: % | Projeto % (cód: %) perdeu 1 participante. Total atual: %', evento, nome_proj_antigo, OLD.codigop, qtd_proj_antigo;

        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        evento := 'UPDATE (Mudança de Projeto)';

        SELECT COUNT(matric) INTO qtd_proj_antigo FROM ALOCACAO WHERE codigop = OLD.codigop;
        SELECT nome INTO nome_proj_antigo FROM PROJETO WHERE codproj = OLD.codigop;

        SELECT COUNT(matric) INTO qtd_proj_novo FROM ALOCACAO WHERE codigop = NEW.codigop;
        SELECT nome INTO nome_proj_novo FROM PROJETO WHERE codproj = NEW.codigop;

        UPDATE TotProj SET QtdProj = qtd_proj_antigo, DtProj = NOW()
        WHERE Cproj = OLD.codigop;

        INSERT INTO TotProj (Cproj, Nproj, QtdProj, DtProj)
        VALUES (NEW.codigop, nome_proj_novo, qtd_proj_novo, NOW())
        ON CONFLICT (Cproj) DO UPDATE SET
            QtdProj = EXCLUDED.QtdProj,
            DtProj = EXCLUDED.DtProj;

        RAISE NOTICE 'Evento: % | Projeto ANTIGO: % (Total: %) | Projeto NOVO: % (Total: %)', evento, nome_proj_antigo, qtd_proj_antigo, nome_proj_novo, qtd_proj_novo;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_AtualizaTotProj
AFTER INSERT OR UPDATE OF codigop OR DELETE ON ALOCACAO
FOR EACH ROW
EXECUTE FUNCTION trg_atualiza_totproj();