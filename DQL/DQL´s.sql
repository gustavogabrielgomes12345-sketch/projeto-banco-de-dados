-- ============================================================================
-- 5. CONSULTAS DE BANCO DE DADOS (DQL) - OFICINA MECÂNICA
-- ============================================================================

SELECT
    c.id AS cliente_id,                       
    c.nome AS cliente,                        
    SUM(os.valor_total) AS faturamento_total  
FROM clientes c
INNER JOIN ordens_servico os ON os.cliente_id = c.id
WHERE os.status = 'CONCLUIDA'                 
GROUP BY c.id, c.nome
ORDER BY faturamento_total DESC;

SELECT
    p.id AS peca_id,                          
    p.nome AS peca,                           
    COALESCE(SUM(osp.quantidade), 0) AS total_saidas, 
    e.quantidade_atual AS saldo_estoque       
FROM pecas p
LEFT JOIN ordens_servico_pecas osp ON osp.peca_id = p.id
LEFT JOIN estoques e ON e.peca_id = p.id
GROUP BY p.id, p.nome, e.quantidade_atual
ORDER BY total_saidas DESC;

SELECT
    f.id AS mecano_id,                       
    f.nome AS mecanico,                       
    SUM(oss.valor_cobrado) AS total_mao_de_obra 
FROM funcionarios f
INNER JOIN ordens_servico_servicos oss ON oss.funcionario_id = f.id
GROUP BY f.id, f.nome
ORDER BY total_mao_de_obra DESC;

SELECT
    os.id AS ordem_servico_id,               
    c.nome AS cliente,                        
    os.data_abertura,                         
    os.valor_total                            
FROM ordens_servico os
INNER JOIN clientes c ON c.id = os.cliente_id
LEFT JOIN pagamentos p ON p.ordem_servico_id = os.id
WHERE os.status = 'CONCLUIDA'                 
  AND p.id IS NULL;                           

SELECT
    p.id AS peca_id,                          
    p.nome AS peca,                           
    e.quantidade_atual,                       
    e.quantidade_minima,                      
    (e.quantidade_minima - e.quantidade_atual) AS quantidade_a_repor 
FROM estoques e
INNER JOIN pecas p ON p.id = e.peca_id
WHERE e.quantidade_atual < e.quantidade_minima
ORDER BY quantidade_a_repor DESC;

SELECT
    v.marca,                                  
    AVG(os.valor_total) AS ticket_medio       
FROM ordens_servico os
INNER JOIN veiculos v ON v.id = os.veiculo_id
WHERE os.status = 'CONCLUIDA'
GROUP BY v.marca
ORDER BY ticket_medio DESC;

SELECT
    f.id AS mecano_id,                       
    f.nome AS mecanico,                       
    AVG(EXTRACT(EPOCH FROM (os.data_conclusao - os.data_abertura))/3600) AS tempo_medio_horas 
FROM ordens_servico os
INNER JOIN funcionarios f ON f.id = os.funcionario_id
WHERE os.status = 'CONCLUIDA'
  AND os.data_conclusao IS NOT NULL
GROUP BY f.id, f.nome;

SELECT
    p.id AS peca_id,                         
    p.nome AS peca,                           
    p.preco_venda                             
FROM pecas p
LEFT JOIN ordens_servico_pecas osp ON osp.peca_id = p.id
WHERE osp.id IS NULL;                         

SELECT
    p.id AS peca_id,                          
    p.nome AS peca,                           
    p.preco_custo,                            
    p.preco_venda,                            
    (p.preco_venda - p.preco_custo) AS margem_bruta_valor,
    ROUND(((p.preco_venda - p.preco_custo) / p.preco_custo) * 100, 2) AS margem_percentual 
FROM pecas p
ORDER BY margem_bruta_valor DESC;

SELECT
    s.id AS servico_id,                       
    s.nome AS servico,                        
    COUNT(oss.id) AS quantidade_solicitacoes 
FROM ordens_servico_servicos oss
INNER JOIN servicos s ON s.id = oss.servico_id
GROUP BY s.id, s.nome
ORDER BY quantidade_solicitacoes DESC
LIMIT 5;

SELECT
    f.id AS fornecedor_id,                    
    f.razao_social AS fornecedor,             
    COALESCE(SUM(me.quantidade), 0) AS total_pecas_recebidas 
FROM fornecedores f
INNER JOIN pecas p ON p.fornecedor_id = f.id
INNER JOIN movimentacoes_estoque me ON me.peca_id = p.id
WHERE me.tipo_movimentacao = 'ENTRADA'        
GROUP BY f.id, f.razao_social
ORDER BY total_pecas_recebidas DESC;

SELECT
    v.id AS veiculo_id,                       
    v.placa,                                  
    v.modelo,                                 
    COUNT(os.id) AS total_ordens_servico      
FROM veiculos v
INNER JOIN ordens_servico os ON os.veiculo_id = v.id
WHERE EXTRACT(YEAR FROM os.data_abertura) = EXTRACT(YEAR FROM CURRENT_DATE) 
GROUP BY v.id, v.placa, v.modelo
HAVING COUNT(os.id) > 3;                      

SELECT
    fp.id AS forma_pagamento_id,              
    fp.descricao AS forma_pagamento,          
    SUM(p.valor) AS total_faturado            
FROM pagamentos p
INNER JOIN formas_pagamento fp ON fp.id = p.forma_pagamento_id
GROUP BY fp.id, fp.descricao
ORDER BY total_faturado DESC;

SELECT
    os.id AS ordem_servico_id,               
    COALESCE(SUM(osp.quantidade * osp.preco_unitario), 0) AS total_pecas, 
    COALESCE(SUM(oss.valor_cobrado), 0) AS total_mao_de_obra             
FROM ordens_servico os
LEFT JOIN ordens_servico_pecas osp ON osp.ordem_servico_id = os.id
LEFT JOIN ordens_servico_servicos oss ON oss.ordem_servico_id = os.id
GROUP BY os.id
HAVING COALESCE(SUM(osp.quantidade * osp.preco_unitario), 0) > COALESCE(SUM(oss.valor_cobrado), 0);

SELECT
    v.placa,                                  
    v.modelo,                                 
    MAX(os.data_conclusao) AS data_ultima_revisao 
FROM veiculos v
INNER JOIN ordens_servico os ON os.veiculo_id = v.id
WHERE os.status = 'CONCLUIDA'
GROUP BY v.placa, v.modelo;

SELECT
    p.id AS peca_id,                          
    p.nome AS peca,                           
    COALESCE(SUM(me.quantidade), 0) AS volume_total_movimentado 
FROM pecas p
LEFT JOIN movimentacoes_estoque me ON me.peca_id = p.id
GROUP BY p.id, p.nome
ORDER BY volume_total_movimentado DESC;

SELECT
    SUM(os.valor_total) AS total_inadimplencia 
FROM ordens_servico os
LEFT JOIN pagamentos p ON p.ordem_servico_id = os.id
WHERE os.status = 'CONCLUIDA'
  AND p.id IS NULL;                           

SELECT
    f.id AS funcionario_id,                   
    f.nome AS mecanico                        
FROM funcionarios f
INNER JOIN tipos_funcionario tf ON tf.id = f.tipo_funcionario_id
WHERE tf.descricao = 'Mecânico'
  AND f.id NOT IN (
      SELECT os.funcionario_id
      FROM ordens_servico os
      WHERE DATE(os.data_abertura) = CURRENT_DATE 
  );

SELECT
    SUM(oss.desconto_concedido) AS total_descontos_concedidos 
FROM ordens_servico_servicos oss;

SELECT
    os.id AS ordem_servico_id,               
    c.nome AS cliente,                       
    v.placa AS placa_veiculo,                
    v.modelo AS modelo_veiculo,              
    f.nome AS mecanico_responsavel,          
    os.status,                               
    os.valor_total                           
FROM ordens_servico os
INNER JOIN clientes c ON c.id = os.cliente_id
INNER JOIN veiculos v ON v.id = os.veiculo_id
INNER JOIN funcionarios f ON f.id = os.funcionario_id
ORDER BY os.id ASC;
