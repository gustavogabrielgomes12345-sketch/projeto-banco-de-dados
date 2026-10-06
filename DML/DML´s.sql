-- ============================================================================
-- INSERÇÃO DE DADOS DE TESTE (DML)
-- População em ordem para garantir a integridade das chaves estrangeiras.
-- ============================================================================

-- 1. Carga na tabela de clientes
INSERT INTO clientes (id, nome, cpf_cnpj, telefone, email, endereco, data_cadastro, ativo) VALUES
(1, 'Marcos Andrade',    '111.111.111-11', '(71) 90000-0001', 'marcos.andrade@email.com',  'Rua das Flores, 100',  '2024-02-10', TRUE),
(2, 'Juliana Ferreira', '222.222.222-22', '(71) 90000-0002', 'juliana.ferreira@email.com', 'Av. Central, 200',    '2024-05-22', TRUE),
(3, 'Comercial Sol Ltda','11.222.333/0001-44', '(71) 90000-0003', 'contato@sol.com.br',    'Rua do Comércio, 55', '2025-01-15', TRUE),
(4, 'Renato Souza',     '333.333.333-33', '(71) 90000-0004', 'renato.souza@email.com',    'Travessa Nova, 10',    '2025-03-30', FALSE);

-- 2. Carga na tabela de veículos (cliente_id aponta para clientes.id)
INSERT INTO veiculos (id, placa, marca, modelo, ano_fabricacao, ano_modelo, cor, quilometragem, cliente_id) VALUES
(1, 'ABC1D23', 'Fiat',       'Uno',      2018, 2019, 'Branco',  68000, 1),
(2, 'XYZ9K88', 'Chevrolet',  'Onix',     2021, 2021, 'Prata',   32000, 2),
(3, 'JJK4L56', 'Volkswagen', 'Gol',      2015, 2015, 'Preto',  102000, 1),
(4, 'MNP7Q11', 'Ford',       'Ranger',   2022, 2023, 'Cinza',   15000, 3);

-- 3. Carga na tabela de cargos de funcionário
INSERT INTO tipos_funcionario (id, descricao) VALUES
(1, 'Mecânico'),
(2, 'Atendente'),
(3, 'Gerente'),
(4, 'Caixa');

-- 4. Carga na tabela de funcionários (tipo_funcionario_id aponta para tipos_funcionario.id)
INSERT INTO funcionarios (id, nome, cpf, telefone, data_admissao, salario, ativo, tipo_funcionario_id) VALUES
(1, 'Carlos Lima',    '444.444.444-44', '(71) 90000-1001', '2022-01-10', 3200.00, TRUE, 1),
(2, 'Fernanda Alves', '555.555.555-55', '(71) 90000-1002', '2023-06-01', 2400.00, TRUE, 2),
(3, 'Roberto Nunes',  '666.666.666-66', '(71) 90000-1003', '2020-03-15', 5200.00, TRUE, 3),
(4, 'Patrícia Gomes', '777.777.777-77', '(71) 90000-1004', '2024-08-20', 2200.00, TRUE, 4);

-- 5. Carga na tabela de fornecedores
INSERT INTO fornecedores (id, razao_social, cnpj, telefone, email, endereco) VALUES
(1, 'AutoPeças Bahia Ltda',    '22.333.444/0001-55', '(71) 3200-1000', 'vendas@autopecasbahia.com.br', 'Av. Industrial, 500'),
(2, 'Distribuidora Motor Sul', '33.444.555/0001-66', '(71) 3200-2000', 'comercial@motorsul.com.br',    'Rua das Oficinas, 300');

-- 6. Carga na tabela de categorias de peças
INSERT INTO categorias_peca (id, descricao) VALUES
(1, 'Motor'),
(2, 'Freios'),
(3, 'Suspensão'),
(4, 'Elétrica'),
(5, 'Filtros e Fluidos');

-- 7. Carga na tabela de peças (categoria_peca_id e fornecedor_id apontam para os devidos ids)
INSERT INTO pecas (id, nome, descricao, preco_custo, preco_venda, unidade_medida, categoria_peca_id, fornecedor_id) VALUES
(1, 'Óleo de Motor 5W30 (1L)', 'Óleo sintético',            18.00,  32.00, 'UN', 5, 1),
(2, 'Filtro de Óleo',          'Filtro de óleo padrão',      8.00,  18.00, 'UN', 5, 1),
(3, 'Pastilha de Freio',       'Jogo de pastilhas',         45.00,  89.00, 'JG', 2, 2),
(4, 'Amortecedor Dianteiro',   'Amortecedor a gás',        120.00, 210.00, 'UN', 3, 2),
(5, 'Bateria 60Ah',            'Bateria automotiva',       280.00, 420.00, 'UN', 4, 1),
(6, 'Vela de Ignição',         'Jogo de velas',             30.00,  60.00, 'JG', 1, 1);

-- 8. Carga na tabela de estoques (peca_id aponta para pecas.id)
INSERT INTO estoques (id, peca_id, quantidade_atual, quantidade_minima, localizacao, data_atualizacao) VALUES
(1, 1, 40, 10, 'Prateleira A1', CURRENT_DATE),
(2, 2, 25, 10, 'Prateleira A2', CURRENT_DATE),
(3, 3,  4,  8, 'Prateleira B1', CURRENT_DATE), 
(4, 4,  6,  5, 'Prateleira C1', CURRENT_DATE),
(5, 5,  3,  5, 'Prateleira D1', CURRENT_DATE),
(6, 6, 15,  5, 'Prateleira E1', CURRENT_DATE);

-- 9. Carga na tabela de movimentações de estoque
INSERT INTO movimentacoes_estoque (id, peca_id, tipo_movimentacao, quantidade, data_movimentacao, observacao) VALUES
(1, 1, 'ENTRADA', 50, CURRENT_TIMESTAMP - INTERVAL '15 DAYS', 'Compra fornecedor AutoPeças Bahia'),
(2, 1, 'SAIDA',   10, CURRENT_TIMESTAMP - INTERVAL '10 DAYS', 'Uso em ordem de serviço'),
(3, 3, 'ENTRADA', 10, CURRENT_TIMESTAMP - INTERVAL '20 DAYS', 'Compra fornecedor Motor Sul'),
(4, 3, 'SAIDA',    6, CURRENT_TIMESTAMP - INTERVAL '5 DAYS',  'Uso em ordem de serviço'),
(5, 5, 'SAIDA',    2, CURRENT_TIMESTAMP - INTERVAL '2 DAYS',  'Uso em ordem de serviço');

-- 10. Carga na tabela de catálogo de serviços
INSERT INTO servicos (id, nome, descricao, valor, tempo_estimado_min) VALUES
(1, 'Troca de Óleo',               'Troca de óleo e filtro',            80.00, 40),
(2, 'Alinhamento e Balanceamento', 'Alinhamento de direção',          120.00, 60),
(3, 'Revisão de Freios',           'Verificação e troca de pastilhas', 150.00, 90),
(4, 'Troca de Bateria',            'Substituição da bateria',            50.00, 20);

-- 11. Carga na tabela de ordens de serviço
INSERT INTO ordens_servico (id, cliente_id, veiculo_id, funcionario_id, data_abertura, data_previsao, data_conclusao, status, valor_total, observacoes) VALUES
(1, 1, 1, 1, CURRENT_TIMESTAMP - INTERVAL '5 DAYS', CURRENT_DATE - 5, CURRENT_TIMESTAMP - INTERVAL '5 DAYS', 'CONCLUIDA', 130.00, 'Cliente aguardou no local'),
(2, 1, 3, 1, CURRENT_TIMESTAMP - INTERVAL '3 DAYS', CURRENT_DATE - 3, CURRENT_TIMESTAMP - INTERVAL '3 DAYS', 'CONCLUIDA', 239.00, NULL),
(3, 2, 2, 1, CURRENT_TIMESTAMP - INTERVAL '1 DAYS', CURRENT_DATE + 1, NULL,                                   'EM_ANDAMENTO', 0.00, 'Aguardando liberação'),
(4, 3, 4, 1, CURRENT_TIMESTAMP,                     CURRENT_DATE,     NULL,                                   'ABERTA', 0.00, NULL);

-- 12. Carga na tabela associativa de peças da OS
INSERT INTO ordens_servico_pecas (id, ordem_servico_id, peca_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 1, 32.00),
(2, 1, 2, 1, 18.00),
(3, 2, 3, 1, 89.00),
(4, 3, 5, 1, 420.00);

-- 13. Carga na tabela associativa de serviços da OS
INSERT INTO ordens_servico_servicos (id, ordem_servico_id, servico_id, funcionario_id, valor_cobrado, desconto_concedido) VALUES
(1, 1, 1, 1,  80.00, 10.00),
(2, 2, 3, 1, 150.00,  0.00),
(3, 3, 4, 1,  50.00,  5.00);

-- 14. Carga na tabela de formas de pagamento
INSERT INTO formas_pagamento (id, descricao) VALUES
(1, 'Dinheiro'),
(2, 'Pix'),
(3, 'Cartão de Débito'),
(4, 'Cartão de Crédito'),
(5, 'Boleto');

-- 15. Carga na tabela de pagamentos (ordem_servico_id aponta para ordens_servico.id)
INSERT INTO pagamentos (id, ordem_servico_id, forma_pagamento_id, valor, data_pagamento, parcelas) VALUES
(1, 1, 2, 130.00, CURRENT_TIMESTAMP - INTERVAL '5 DAYS', 1);