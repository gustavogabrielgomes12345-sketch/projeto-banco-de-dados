
INSERT INTO clientes (cliente_id, nome, cpf_cnpj, telefone, email, endereco, data_cadastro, ativo) VALUES
(1, 'Marcos Andrade',   '111.111.111-11', '(71) 90000-0001', 'marcos.andrade@email.com', 'Rua das Flores, 100',  '2024-02-10', TRUE),
(2, 'Juliana Ferreira',  '222.222.222-22', '(71) 90000-0002', 'juliana.ferreira@email.com', 'Av. Central, 200',   '2024-05-22', TRUE),
(3, 'Comercial Sol Ltda','11.222.333/0001-44', '(71) 90000-0003', 'contato@sol.com.br', 'Rua do Comércio, 55', '2025-01-15', TRUE),
(4, 'Renato Souza',      '333.333.333-33', '(71) 90000-0004', 'renato.souza@email.com', 'Travessa Nova, 10',   '2025-03-30', FALSE);


INSERT INTO veiculos (veiculo_id, placa, marca, modelo, ano_fabricacao, ano_modelo, cor, quilometragem, cliente_id) VALUES
(1, 'ABC1D23', 'Fiat',       'Uno',      2018, 2019, 'Branco', 68000, 1),
(2, 'XYZ9K88', 'Chevrolet',  'Onix',     2021, 2021, 'Prata',  32000, 2),
(3, 'JJK4L56', 'Volkswagen', 'Gol',      2015, 2015, 'Preto', 102000, 1),
(4, 'MNP7Q11', 'Ford',       'Ranger',   2022, 2023, 'Cinza',  15000, 3);


INSERT INTO tipos_funcionario (tipo_funcionario_id, descricao) VALUES
(1, 'Mecânico'),
(2, 'Atendente'),
(3, 'Gerente'),
(4, 'Caixa');


INSERT INTO funcionarios (funcionario_id, nome, cpf, telefone, data_admissao, salario, ativo, tipo_funcionario_id) VALUES
(1, 'Carlos Lima',    '444.444.444-44', '(71) 90000-1001', '2022-01-10', 3200.00, TRUE, 1),
(2, 'Fernanda Alves', '555.555.555-55', '(71) 90000-1002', '2023-06-01', 2400.00, TRUE, 2),
(3, 'Roberto Nunes',  '666.666.666-66', '(71) 90000-1003', '2020-03-15', 5200.00, TRUE, 3),
(4, 'Patrícia Gomes', '777.777.777-77', '(71) 90000-1004', '2024-08-20', 2200.00, TRUE, 4);


INSERT INTO fornecedores (fornecedor_id, razao_social, cnpj, telefone, email, endereco) VALUES
(1, 'AutoPeças Bahia Ltda',   '22.333.444/0001-55', '(71) 3200-1000', 'vendas@autopecasbahia.com.br', 'Av. Industrial, 500'),
(2, 'Distribuidora Motor Sul','33.444.555/0001-66', '(71) 3200-2000', 'comercial@motorsul.com.br',    'Rua das Oficinas, 300');


INSERT INTO categorias_peca (categoria_peca_id, descricao) VALUES
(1, 'Motor'),
(2, 'Freios'),
(3, 'Suspensão'),
(4, 'Elétrica'),
(5, 'Filtros e Fluidos');


INSERT INTO pecas (peca_id, nome, descricao, preco_custo, preco_venda, unidade_medida, categoria_peca_id, fornecedor_id) VALUES
(1, 'Óleo de Motor 5W30 (1L)', 'Óleo sintético',           18.00, 32.00, 'UN', 5, 1),
(2, 'Filtro de Óleo',          'Filtro de óleo padrão',     8.00, 18.00, 'UN', 5, 1),
(3, 'Pastilha de Freio Dianteira', 'Jogo de pastilhas',    45.00, 89.00, 'JG', 2, 2),
(4, 'Amortecedor Dianteiro',   'Amortecedor a gás',       120.00, 210.00, 'UN', 3, 2),
(5, 'Bateria 60Ah',            'Bateria automotiva',      280.00, 420.00, 'UN', 4, 1);


INSERT INTO estoques (estoque_id, peca_id, quantidade_atual, quantidade_minima, localizacao, data_atualizacao) VALUES
(1, 1, 40, 10, 'Prateleira A1', '2026-08-20'),
(2, 2, 25, 10, 'Prateleira A2', '2026-08-20'),
(3, 3, 4,  8,  'Prateleira B1', '2026-08-20'), 
(4, 4, 6,  5,  'Prateleira C1', '2026-08-20'),
(5, 5, 3,  5,  'Prateleira D1', '2026-08-20'); 


INSERT INTO movimentacoes_estoque (movimentacao_estoque_id, peca_id, tipo_movimentacao, quantidade, data_movimentacao, observacao) VALUES
(1, 1, 'ENTRADA', 50, '2026-08-01 09:00:00', 'Compra fornecedor AutoPeças Bahia'),
(2, 1, 'SAIDA',   10, '2026-08-15 14:30:00', 'Uso em ordem de serviço'),
(3, 3, 'ENTRADA', 10, '2026-07-20 10:00:00', 'Compra fornecedor Motor Sul'),
(4, 3, 'SAIDA',    6, '2026-08-18 11:15:00', 'Uso em ordem de serviço'),
(5, 5, 'SAIDA',    2, '2026-08-19 16:00:00', 'Uso em ordem de serviço');

INSERT INTO servicos (servico_id, nome, descricao, valor, tempo_estimado_min) VALUES
(1, 'Troca de Óleo',              'Troca de óleo e filtro',           80.00, 40),
(2, 'Alinhamento e Balanceamento','Alinhamento de direção e balanceamento', 120.00, 60),
(3, 'Revisão de Freios',          'Verificação e troca de pastilhas', 150.00, 90),
(4, 'Troca de Bateria',           'Substituição da bateria',           50.00, 20);

INSERT INTO ordens_servico (ordem_servico_id, cliente_id, veiculo_id, funcionario_id, data_abertura, data_previsao, data_conclusao, status, valor_total, observacoes) VALUES
(1, 1, 1, 1, '2026-08-15 08:30:00', '2026-08-15', '2026-08-15 10:10:00', 'CONCLUIDA', 130.00, 'Cliente aguardou no local'),
(2, 1, 3, 1, '2026-08-18 09:00:00', '2026-08-18', '2026-08-18 11:00:00', 'CONCLUIDA', 239.00, NULL),
(3, 2, 2, 2, '2026-08-20 13:00:00', '2026-08-21', NULL,                  'EM_ANDAMENTO', 0.00, 'Aguardando peça'),
(4, 3, 4, 1, '2026-08-24 10:00:00', '2026-08-24', NULL,                  'ABERTA', 0.00, NULL);


INSERT INTO ordens_servico_pecas (ordem_servico_peca_id, ordem_servico_id, peca_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 1, 32.00),
(2, 1, 2, 1, 18.00),
(3, 2, 3, 1, 89.00),
(4, 3, 5, 1, 420.00);


INSERT INTO ordens_servico_servicos (ordem_servico_servico_id, ordem_servico_id, servico_id, funcionario_id, valor_cobrado) VALUES
(1, 1, 1, 1, 80.00),
(2, 2, 3, 1, 150.00),
(3, 3, 4, 2, 50.00);


INSERT INTO formas_pagamento (forma_pagamento_id, descricao) VALUES
(1, 'Dinheiro'),
(2, 'Pix'),
(3, 'Cartão de Débito'),
(4, 'Cartão de Crédito'),
(5, 'Boleto');

INSERT INTO pagamentos (pagamento_id, ordem_servico_id, forma_pagamento_id, valor, data_pagamento, parcelas) VALUES
(1, 1, 2, 130.00, '2026-08-15 10:15:00', 1),
(2, 2, 4, 239.00, '2026-08-18 11:05:00', 2);
