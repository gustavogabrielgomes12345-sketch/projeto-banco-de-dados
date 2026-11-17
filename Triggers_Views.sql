-- TRIGGERS E VIEWS - OFICINA MECANICA
-- postgres. rodar depois do DDL, do DML e do PSM_procedures_functions.sql
-- (usa coisa que o PSM criou: quantidade_reservada, cobrancas, valor_desconto...)


-- 0. coisas novas na estrutura

-- tabela de log pro trigger 4 (reajuste de preco)
CREATE TABLE IF NOT EXISTS log_preco_pecas (
    id              INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    peca_id         INT NOT NULL,
    preco_antigo    DECIMAL(10,2) NOT NULL,
    preco_novo      DECIMAL(10,2) NOT NULL,
    data_alteracao  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario         VARCHAR(100) NOT NULL DEFAULT CURRENT_USER
);


-- 1. mexi em duas procedures
-- como agora os triggers 1 e 3 reservam e dao baixa no estoque, as procedures
-- nao podem fazer isso tambem, senao desconta 2x. So tirei essa parte,
-- o resto ta igual.

-- sp_adicionar_peca_ordem_servico (tirei o UPDATE da reserva)
CREATE OR REPLACE PROCEDURE sp_adicionar_peca_ordem_servico(
    p_os_id INT,
    p_peca_id INT,
    p_quantidade INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
    v_preco NUMERIC;
    v_disponivel INT;
    v_item_id INT;
BEGIN
    IF p_quantidade <= 0 THEN
        RAISE EXCEPTION 'Quantidade tem que ser maior que zero';
    END IF;

    SELECT status INTO v_status FROM ordens_servico WHERE id = p_os_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'OS % nao encontrada', p_os_id;
    END IF;
    IF v_status NOT IN ('EM_ANALISE', 'ABERTA', 'EM_ANDAMENTO') THEN
        RAISE EXCEPTION 'OS % esta com status % e nao aceita pecas', p_os_id, v_status;
    END IF;

    SELECT preco_venda INTO v_preco FROM pecas WHERE id = p_peca_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Peca % nao cadastrada', p_peca_id;
    END IF;

    SELECT quantidade_atual - quantidade_reservada INTO v_disponivel
    FROM estoques WHERE peca_id = p_peca_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Peca % sem registro de estoque', p_peca_id;
    END IF;
    IF v_disponivel < p_quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente da peca % (disponivel: %, pedido: %)', p_peca_id, v_disponivel, p_quantidade;
    END IF;

    -- se a peca ja ta na OS soma a quantidade, senao insere
    -- (quem reserva no estoque agora e o tg_reservar_estoque_peca_os)
    SELECT id INTO v_item_id FROM ordens_servico_pecas
    WHERE ordem_servico_id = p_os_id AND peca_id = p_peca_id;

    IF FOUND THEN
        UPDATE ordens_servico_pecas SET quantidade = quantidade + p_quantidade WHERE id = v_item_id;
    ELSE
        INSERT INTO ordens_servico_pecas (id, ordem_servico_id, peca_id, quantidade, preco_unitario)
        SELECT COALESCE(MAX(id), 0) + 1, p_os_id, p_peca_id, p_quantidade, v_preco
        FROM ordens_servico_pecas;
    END IF;

    -- valor parcial das pecas
    UPDATE ordens_servico
    SET valor_pecas = (SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
                       FROM ordens_servico_pecas WHERE ordem_servico_id = p_os_id)
    WHERE id = p_os_id;
END;
$$;


-- sp_finalizar_ordem_servico (tirei o loop da baixa no estoque, o trigger 3 faz)
CREATE OR REPLACE PROCEDURE sp_finalizar_ordem_servico(
    p_os_id INT,
    p_data_vencimento DATE DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
    v_pecas NUMERIC;
    v_mao_obra NUMERIC;
    v_vencimento DATE;
BEGIN
    SELECT status INTO v_status FROM ordens_servico WHERE id = p_os_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'OS % nao encontrada', p_os_id;
    END IF;
    IF v_status NOT IN ('EM_ANALISE', 'ABERTA', 'EM_ANDAMENTO') THEN
        RAISE EXCEPTION 'OS % esta com status % e nao pode ser finalizada', p_os_id, v_status;
    END IF;

    -- se nao informar vencimento, 7 dias
    v_vencimento := COALESCE(p_data_vencimento, CURRENT_DATE + 7);

    SELECT COALESCE(SUM(quantidade * preco_unitario), 0) INTO v_pecas
    FROM ordens_servico_pecas WHERE ordem_servico_id = p_os_id;

    SELECT COALESCE(SUM(valor_cobrado), 0) INTO v_mao_obra
    FROM ordens_servico_servicos WHERE ordem_servico_id = p_os_id;

    -- aqui disparam o tg_impedir_finalizacao_os_sem_servico (antes)
    -- e o tg_dar_baixa_definitiva_estoque_conclusao_os (depois)
    UPDATE ordens_servico
    SET status = 'FINALIZADA',
        data_conclusao = CURRENT_TIMESTAMP,
        valor_pecas = v_pecas,
        valor_mao_obra = v_mao_obra,
        valor_total = v_pecas + v_mao_obra
    WHERE id = p_os_id;

    -- cobranca
    INSERT INTO cobrancas (id, ordem_servico_id, valor, data_emissao, data_vencimento, status)
    SELECT COALESCE(MAX(id), 0) + 1, p_os_id, v_pecas + v_mao_obra, CURRENT_DATE, v_vencimento, 'PENDENTE'
    FROM cobrancas;
END;
$$;


-- 2. TRIGGERS
-- cada um tem a function (fn_...) que faz o servico e o CREATE TRIGGER embaixo

-- 1. tg_reservar_estoque_peca_os
-- peca entrou numa OS EM_ANDAMENTO -> reserva no estoque.
-- Se mudar a quantidade reserva so a diferenca, e se apagar a peca da OS
-- libera a reserva.
-- obs: peca colocada antes da OS virar EM_ANDAMENTO nao reserva nada
CREATE OR REPLACE FUNCTION fn_reservar_estoque_peca_os()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_os_id INT;
    v_peca_id INT;
    v_delta INT;
    v_status VARCHAR(20);
    v_disponivel INT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_os_id := NEW.ordem_servico_id;
        v_peca_id := NEW.peca_id;
        v_delta := NEW.quantidade;
    ELSIF TG_OP = 'UPDATE' THEN
        v_os_id := NEW.ordem_servico_id;
        v_peca_id := NEW.peca_id;
        v_delta := NEW.quantidade - OLD.quantidade;
    ELSE
        v_os_id := OLD.ordem_servico_id;
        v_peca_id := OLD.peca_id;
        v_delta := -OLD.quantidade;
    END IF;

    IF v_delta = 0 THEN
        RETURN NULL;
    END IF;

    SELECT status INTO v_status FROM ordens_servico WHERE id = v_os_id;
    IF v_status IS DISTINCT FROM 'EM_ANDAMENTO' THEN
        RETURN NULL;
    END IF;

    -- so confere o saldo quando ta reservando mais
    IF v_delta > 0 THEN
        SELECT quantidade_atual - quantidade_reservada INTO v_disponivel
        FROM estoques WHERE peca_id = v_peca_id FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Peca % sem registro de estoque', v_peca_id;
        END IF;
        IF v_disponivel < v_delta THEN
            RAISE EXCEPTION 'Estoque insuficiente para reservar a peca % (disponivel: %, pedido: %)',
                v_peca_id, v_disponivel, v_delta;
        END IF;
    END IF;

    UPDATE estoques
    SET quantidade_reservada = GREATEST(quantidade_reservada + v_delta, 0),
        data_atualizacao = CURRENT_DATE
    WHERE peca_id = v_peca_id;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tg_reservar_estoque_peca_os ON ordens_servico_pecas;
CREATE TRIGGER tg_reservar_estoque_peca_os
AFTER INSERT OR DELETE OR UPDATE OF quantidade ON ordens_servico_pecas
FOR EACH ROW
EXECUTE FUNCTION fn_reservar_estoque_peca_os();


-- 2. tg_impedir_finalizacao_os_sem_servico
-- BEFORE UPDATE: se a OS vai virar FINALIZADA e nao tem peca nem servico, barra
CREATE OR REPLACE FUNCTION fn_impedir_finalizacao_os_sem_servico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status = 'FINALIZADA' AND OLD.status IS DISTINCT FROM 'FINALIZADA' THEN
        IF NOT EXISTS (SELECT 1 FROM ordens_servico_pecas WHERE ordem_servico_id = NEW.id)
           AND NOT EXISTS (SELECT 1 FROM ordens_servico_servicos WHERE ordem_servico_id = NEW.id) THEN
            RAISE EXCEPTION 'OS % nao pode ser finalizada: nao tem pecas nem servicos', NEW.id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_impedir_finalizacao_os_sem_servico ON ordens_servico;
CREATE TRIGGER tg_impedir_finalizacao_os_sem_servico
BEFORE UPDATE OF status ON ordens_servico
FOR EACH ROW
EXECUTE FUNCTION fn_impedir_finalizacao_os_sem_servico();


-- 3. tg_dar_baixa_definitiva_estoque_conclusao_os
-- OS concluida -> tira a quantidade do saldo e da reserva e registra a SAIDA.
-- No nosso sistema CONCLUIDA e FINALIZADA querem dizer a mesma coisa, entao o
-- WHEN pega os dois, mas so na primeira vez que chega num deles (assim
-- FINALIZADA -> CONCLUIDA ou -> PAGA nao baixa de novo)
CREATE OR REPLACE FUNCTION fn_dar_baixa_definitiva_estoque_conclusao_os()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_item RECORD;
BEGIN
    FOR v_item IN SELECT peca_id, quantidade FROM ordens_servico_pecas WHERE ordem_servico_id = NEW.id
    LOOP
        UPDATE estoques
        SET quantidade_atual = quantidade_atual - v_item.quantidade,
            quantidade_reservada = GREATEST(quantidade_reservada - v_item.quantidade, 0),
            data_atualizacao = CURRENT_DATE
        WHERE peca_id = v_item.peca_id
          AND quantidade_atual >= v_item.quantidade;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Saldo insuficiente da peca % para concluir a OS %', v_item.peca_id, NEW.id;
        END IF;

        INSERT INTO movimentacoes_estoque (id, peca_id, tipo_movimentacao, quantidade, data_movimentacao, observacao)
        SELECT COALESCE(MAX(id), 0) + 1, v_item.peca_id, 'SAIDA', v_item.quantidade,
               CURRENT_TIMESTAMP, 'Uso na ordem de servico ' || NEW.id
        FROM movimentacoes_estoque;
    END LOOP;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tg_dar_baixa_definitiva_estoque_conclusao_os ON ordens_servico;
CREATE TRIGGER tg_dar_baixa_definitiva_estoque_conclusao_os
AFTER UPDATE OF status ON ordens_servico
FOR EACH ROW
WHEN (NEW.status IN ('CONCLUIDA', 'FINALIZADA')
      AND OLD.status NOT IN ('CONCLUIDA', 'FINALIZADA', 'PAGA'))
EXECUTE FUNCTION fn_dar_baixa_definitiva_estoque_conclusao_os();


-- 4. tg_auditoria_reajuste_preco_pecas
-- mudou o preco de venda -> grava no log o preco antigo, o novo, data e usuario
CREATE OR REPLACE FUNCTION fn_auditoria_reajuste_preco_pecas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO log_preco_pecas (peca_id, preco_antigo, preco_novo, data_alteracao, usuario)
    VALUES (OLD.id, OLD.preco_venda, NEW.preco_venda, CURRENT_TIMESTAMP, CURRENT_USER);

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tg_auditoria_reajuste_preco_pecas ON pecas;
CREATE TRIGGER tg_auditoria_reajuste_preco_pecas
AFTER UPDATE OF preco_venda ON pecas
FOR EACH ROW
WHEN (OLD.preco_venda IS DISTINCT FROM NEW.preco_venda)
EXECUTE FUNCTION fn_auditoria_reajuste_preco_pecas();


-- 5. tg_impedir_exclusao_cliente_com_os_aberta
-- antes de apagar o cliente, procura OS em aberto nos veiculos dele
CREATE OR REPLACE FUNCTION fn_impedir_exclusao_cliente_com_os_aberta()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_qtd INT;
BEGIN
    SELECT COUNT(*) INTO v_qtd
    FROM ordens_servico os
    JOIN veiculos v ON v.id = os.veiculo_id
    WHERE v.cliente_id = OLD.id
      AND os.status IN ('ABERTA', 'EM_ANALISE', 'EM_ANDAMENTO');

    IF v_qtd > 0 THEN
        RAISE EXCEPTION 'Cliente % nao pode ser excluido: tem % OS em aberto', OLD.id, v_qtd;
    END IF;

    RETURN OLD;
END;
$$;

DROP TRIGGER IF EXISTS tg_impedir_exclusao_cliente_com_os_aberta ON clientes;
CREATE TRIGGER tg_impedir_exclusao_cliente_com_os_aberta
BEFORE DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION fn_impedir_exclusao_cliente_com_os_aberta();


-- 3. VIEWS

-- 1. vw_relatorio_faturamento_os
-- OS finalizadas com pecas, mao de obra, descontos e forma de pagamento.
-- Pecas e servicos ficam em subselects separados senao as linhas se multiplicam.
CREATE OR REPLACE VIEW vw_relatorio_faturamento_os AS
SELECT
    os.id AS ordem_servico_id,
    c.nome AS cliente,
    os.data_conclusao,
    COALESCE(p.total_pecas, 0) AS valor_pecas,
    COALESCE(s.total_mao_obra, 0) AS valor_mao_obra,
    COALESCE(p.total_pecas, 0) + COALESCE(s.total_mao_obra, 0) AS valor_total,
    COALESCE(s.total_desconto, 0) AS desconto_servicos,
    COALESCE(pg.valor_desconto, 0) AS desconto_pagamento,
    fp.descricao AS forma_pagamento,
    pg.parcelas,
    pg.valor AS valor_pago
FROM ordens_servico os
INNER JOIN clientes c ON c.id = os.cliente_id
LEFT JOIN (
    SELECT ordem_servico_id, SUM(quantidade * preco_unitario) AS total_pecas
    FROM ordens_servico_pecas
    GROUP BY ordem_servico_id
) p ON p.ordem_servico_id = os.id
LEFT JOIN (
    SELECT ordem_servico_id,
           SUM(valor_cobrado) AS total_mao_obra,
           SUM(desconto_concedido) AS total_desconto
    FROM ordens_servico_servicos
    GROUP BY ordem_servico_id
) s ON s.ordem_servico_id = os.id
LEFT JOIN pagamentos pg ON pg.ordem_servico_id = os.id
LEFT JOIN formas_pagamento fp ON fp.id = pg.forma_pagamento_id
WHERE os.status IN ('CONCLUIDA', 'FINALIZADA', 'PAGA');


-- 2. vw_estoque_pecas_necessidade_reposicao
-- disponivel = atual - reservado. Mostra so as que ficaram abaixo do minimo
CREATE OR REPLACE VIEW vw_estoque_pecas_necessidade_reposicao AS
SELECT
    p.id AS peca_id,
    p.nome AS peca,
    f.razao_social AS fornecedor,
    e.quantidade_atual,
    e.quantidade_reservada,
    (e.quantidade_atual - e.quantidade_reservada) AS quantidade_disponivel,
    e.quantidade_minima,
    (e.quantidade_minima - (e.quantidade_atual - e.quantidade_reservada)) AS quantidade_a_repor,
    p.preco_custo,
    (e.quantidade_minima - (e.quantidade_atual - e.quantidade_reservada)) * p.preco_custo AS custo_reposicao
FROM estoques e
INNER JOIN pecas p ON p.id = e.peca_id
INNER JOIN fornecedores f ON f.id = p.fornecedor_id
WHERE (e.quantidade_atual - e.quantidade_reservada) < e.quantidade_minima;


-- 3. vw_produtividade_mecanicos_mes
-- por mecanico e mes: qtd de OS, mao de obra e tempo medio (em horas).
-- Qtd e tempo vem da OS (mecanico responsavel), a mao de obra vem dos servicos
-- que ele executou, por isso separei em duas CTEs.
CREATE OR REPLACE VIEW vw_produtividade_mecanicos_mes AS
WITH os_mes AS (
    SELECT
        funcionario_id,
        DATE_TRUNC('month', data_conclusao)::DATE AS mes,
        COUNT(*) AS qtd_os,
        AVG(EXTRACT(EPOCH FROM (data_conclusao - data_abertura)) / 3600) AS tempo_medio
    FROM ordens_servico
    WHERE status IN ('CONCLUIDA', 'FINALIZADA', 'PAGA')
      AND data_conclusao IS NOT NULL
    GROUP BY funcionario_id, DATE_TRUNC('month', data_conclusao)
),
mao_obra_mes AS (
    SELECT
        oss.funcionario_id,
        DATE_TRUNC('month', os.data_conclusao)::DATE AS mes,
        SUM(oss.valor_cobrado) AS total_mao_obra
    FROM ordens_servico_servicos oss
    INNER JOIN ordens_servico os ON os.id = oss.ordem_servico_id
    WHERE os.status IN ('CONCLUIDA', 'FINALIZADA', 'PAGA')
      AND os.data_conclusao IS NOT NULL
    GROUP BY oss.funcionario_id, DATE_TRUNC('month', os.data_conclusao)
)
SELECT
    f.id AS mecanico_id,
    f.nome AS mecanico,
    o.mes,
    o.qtd_os AS qtd_os_atendidas,
    COALESCE(m.total_mao_obra, 0) AS total_mao_obra,
    ROUND(o.tempo_medio::NUMERIC, 2) AS tempo_medio_horas
FROM os_mes o
INNER JOIN funcionarios f ON f.id = o.funcionario_id
LEFT JOIN mao_obra_mes m ON m.funcionario_id = o.funcionario_id AND m.mes = o.mes;


-- 4. vw_historico_manutencoes_veiculo
-- junta servicos e pecas de cada OS num historico so (UNION ALL)
CREATE OR REPLACE VIEW vw_historico_manutencoes_veiculo AS
SELECT
    v.placa,
    v.modelo,
    os.id AS ordem_servico_id,
    os.data_abertura,
    os.status,
    'SERVICO' AS tipo_item,
    s.nome AS descricao,
    1 AS quantidade,
    oss.valor_cobrado AS valor
FROM ordens_servico_servicos oss
INNER JOIN ordens_servico os ON os.id = oss.ordem_servico_id
INNER JOIN veiculos v ON v.id = os.veiculo_id
INNER JOIN servicos s ON s.id = oss.servico_id

UNION ALL

SELECT
    v.placa,
    v.modelo,
    os.id AS ordem_servico_id,
    os.data_abertura,
    os.status,
    'PECA' AS tipo_item,
    p.nome AS descricao,
    osp.quantidade,
    osp.quantidade * osp.preco_unitario AS valor
FROM ordens_servico_pecas osp
INNER JOIN ordens_servico os ON os.id = osp.ordem_servico_id
INNER JOIN veiculos v ON v.id = os.veiculo_id
INNER JOIN pecas p ON p.id = osp.peca_id;


-- 5. vw_inadimplencia_contas_receber
-- OS concluidas/finalizadas que ninguem pagou ainda. Se tem cobranca pendente
-- usa o vencimento e o valor dela. As OS antigas do DML nao tem cobranca, ai
-- usa a data de conclusao e o valor_total da OS.
-- (nao calcula multa por atraso, so o valor da cobranca)
CREATE OR REPLACE VIEW vw_inadimplencia_contas_receber AS
SELECT
    c.id AS cliente_id,
    c.nome AS cliente,
    os.id AS ordem_servico_id,
    COALESCE(cb.data_vencimento, os.data_conclusao::DATE) AS data_vencimento,
    GREATEST(CURRENT_DATE - COALESCE(cb.data_vencimento, os.data_conclusao::DATE), 0) AS dias_em_atraso,
    CASE
        WHEN COALESCE(cb.data_vencimento, os.data_conclusao::DATE) < CURRENT_DATE THEN 'EM ATRASO'
        ELSE 'A VENCER'
    END AS situacao,
    COALESCE(cb.valor, os.valor_total) AS valor_devido,
    SUM(COALESCE(cb.valor, os.valor_total)) OVER (PARTITION BY c.id) AS total_devido_cliente
FROM ordens_servico os
INNER JOIN clientes c ON c.id = os.cliente_id
LEFT JOIN cobrancas cb ON cb.ordem_servico_id = os.id AND cb.status = 'PENDENTE'
WHERE os.status IN ('CONCLUIDA', 'FINALIZADA')
  AND NOT EXISTS (SELECT 1 FROM pagamentos pg WHERE pg.ordem_servico_id = os.id);


-- 4. TESTES (tirar o -- para rodar)
-- obs: a OS 3 do DML foi inserida antes dos triggers existirem, entao a peca
-- dela nao ta reservada. Pra testar a reserva usa a OS 4.

-- trigger 1 (reserva): coloca a OS 4 em andamento, adiciona peca e olha o estoque
-- UPDATE ordens_servico SET status = 'EM_ANDAMENTO' WHERE id = 4;
-- CALL sp_adicionar_peca_ordem_servico(4, 1, 2);
-- SELECT peca_id, quantidade_atual, quantidade_reservada FROM estoques WHERE peca_id = 1;  -- reservada = 2

-- trigger 2 (OS vazia nao finaliza): tem que dar erro
-- CALL sp_abrir_ordem_servico(2, 2, 1, 2, 'teste OS vazia', NULL, NULL);
-- UPDATE ordens_servico SET status = 'FINALIZADA' WHERE id = 5;

-- trigger 3 (baixa definitiva): finaliza a OS 4 e olha estoque e movimentacao
-- CALL sp_finalizar_ordem_servico(4);
-- SELECT peca_id, quantidade_atual, quantidade_reservada FROM estoques WHERE peca_id = 1;  -- atual 38, reservada 0
-- SELECT * FROM movimentacoes_estoque ORDER BY id DESC LIMIT 1;

-- trigger 4 (log de preco)
-- UPDATE pecas SET preco_venda = 35.00 WHERE id = 1;
-- SELECT * FROM log_preco_pecas;

-- trigger 5 (cliente com OS aberta): tem que dar erro (OS 3 ta EM_ANDAMENTO)
-- DELETE FROM clientes WHERE id = 2;

-- views
-- SELECT * FROM vw_relatorio_faturamento_os;
-- SELECT * FROM vw_estoque_pecas_necessidade_reposicao;
-- SELECT * FROM vw_produtividade_mecanicos_mes;
-- SELECT * FROM vw_historico_manutencoes_veiculo WHERE placa = 'ABC1D23' ORDER BY data_abertura;
-- SELECT * FROM vw_inadimplencia_contas_receber ORDER BY dias_em_atraso DESC;
