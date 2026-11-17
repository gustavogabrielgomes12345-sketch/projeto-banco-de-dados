-- ============================================================================
-- 4. TRIGGERS E VIEWS - OFICINA MECÂNICA
-- ============================================================================

-- ============================================================================
-- 4.1 FUNÇÕES DE TRIGGER E CRIAÇÃO DOS TRIGGERS
-- ============================================================================

-- 1. tg_reservar_estoque_peca_os
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


-- ============================================================================
-- 4.2 VIEWS
-- ============================================================================
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
