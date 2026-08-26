SELECT
    c.nome        AS cliente,
    v.placa,
    v.marca,
    v.modelo
FROM clientes c
JOIN veiculos v ON v.cliente_id = c.cliente_id
WHERE c.ativo = TRUE
ORDER BY c.nome;

SELECT
    p.nome AS peca,
    e.quantidade_atual,
    e.quantidade_minima,
    (e.quantidade_minima - e.quantidade_atual) AS quantidade_a_repor
FROM estoques e
JOIN pecas p ON p.peca_id = e.peca_id
WHERE e.quantidade_atual < e.quantidade_minima
ORDER BY quantidade_a_repor DESC;

SELECT
    os.ordem_servico_id,
    c.nome    AS cliente,
    v.placa,
    v.modelo,
    f.nome    AS responsavel,
    os.status,
    os.data_abertura,
    os.data_previsao
FROM ordens_servico os
JOIN clientes c      ON c.cliente_id = os.cliente_id
JOIN veiculos v       ON v.veiculo_id = os.veiculo_id
JOIN funcionarios f   ON f.funcionario_id = os.funcionario_id
WHERE os.status IN ('ABERTA', 'EM_ANDAMENTO')
ORDER BY os.data_abertura;

SELECT
    fp.descricao AS forma_pagamento,
    COUNT(pg.pagamento_id) AS quantidade_pagamentos,
    SUM(pg.valor) AS total_recebido
FROM pagamentos pg
JOIN formas_pagamento fp ON fp.forma_pagamento_id = pg.forma_pagamento_id
GROUP BY fp.descricao
ORDER BY total_recebido DESC;

SELECT
    s.nome AS servico,
    COUNT(oss.ordem_servico_servico_id) AS quantidade_execucoes,
    SUM(oss.valor_cobrado) AS receita_total
FROM ordens_servico_servicos oss
JOIN servicos s ON s.servico_id = oss.servico_id
GROUP BY s.nome
ORDER BY quantidade_execucoes DESC;

SELECT
    tf.descricao AS cargo,
    COUNT(f.funcionario_id) AS quantidade_funcionarios
FROM funcionarios f
JOIN tipos_funcionario tf ON tf.tipo_funcionario_id = f.tipo_funcionario_id
WHERE f.ativo = TRUE
GROUP BY tf.descricao
ORDER BY quantidade_funcionarios DESC;

SELECT
    p.nome AS peca,
    me.tipo_movimentacao,
    me.quantidade,
    me.data_movimentacao,
    me.observacao
FROM movimentacoes_estoque me
JOIN pecas p ON p.peca_id = me.peca_id
WHERE p.nome = 'Óleo de Motor 5W30 (1L)'
ORDER BY me.data_movimentacao;

SELECT
    'PECA' AS item_tipo,
    p.nome AS item_descricao,
    osp.quantidade,
    osp.preco_unitario,
    (osp.quantidade * osp.preco_unitario) AS subtotal
FROM ordens_servico_pecas osp
JOIN pecas p ON p.peca_id = osp.peca_id
WHERE osp.ordem_servico_id = 1

UNION ALL

SELECT
    'SERVICO' AS item_tipo,
    s.nome AS item_descricao,
    1 AS quantidade,
    oss.valor_cobrado AS preco_unitario,
    oss.valor_cobrado AS subtotal
FROM ordens_servico_servicos oss
JOIN servicos s ON s.servico_id = oss.servico_id
WHERE oss.ordem_servico_id = 1;

SELECT
    fo.razao_social AS fornecedor,
    COUNT(p.peca_id) AS quantidade_pecas_fornecidas
FROM fornecedores fo
JOIN pecas p ON p.fornecedor_id = fo.fornecedor_id
GROUP BY fo.razao_social
ORDER BY quantidade_pecas_fornecidas DESC;

SELECT
    c.nome AS cliente,
    COUNT(os.ordem_servico_id) AS quantidade_ordens_concluidas,
    SUM(os.valor_total) AS valor_total_gasto
FROM ordens_servico os
JOIN clientes c ON c.cliente_id = os.cliente_id
WHERE os.status = 'CONCLUIDA'
GROUP BY c.nome
ORDER BY valor_total_gasto DESC;