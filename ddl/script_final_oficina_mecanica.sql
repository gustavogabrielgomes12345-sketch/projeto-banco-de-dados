
-- 1) apagar as tabelas (filha antes da mae, senao da erro de FK)
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS ordens_servico_servicos;
DROP TABLE IF EXISTS ordens_servico_pecas;
DROP TABLE IF EXISTS movimentacoes_estoque;
DROP TABLE IF EXISTS estoques;
DROP TABLE IF EXISTS ordens_servico;
DROP TABLE IF EXISTS pecas;
DROP TABLE IF EXISTS veiculos;
DROP TABLE IF EXISTS funcionarios;
DROP TABLE IF EXISTS servicos;
DROP TABLE IF EXISTS fornecedores;
DROP TABLE IF EXISTS categorias_peca;
DROP TABLE IF EXISTS tipos_funcionario;
DROP TABLE IF EXISTS formas_pagamento;
DROP TABLE IF EXISTS clientes;


-- 2) criar as tabelas (mae antes da filha)

CREATE TABLE clientes (
    cliente_id      INT PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    cpf_cnpj        VARCHAR(20)  NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    data_cadastro   DATE NOT NULL,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_clientes_cpf_cnpj UNIQUE (cpf_cnpj)
);

CREATE TABLE tipos_funcionario (
    tipo_funcionario_id INT PRIMARY KEY,
    descricao            VARCHAR(50) NOT NULL,
    CONSTRAINT uq_tipos_funcionario_descricao UNIQUE (descricao)
);

CREATE TABLE formas_pagamento (
    forma_pagamento_id  INT PRIMARY KEY,
    descricao           VARCHAR(30) NOT NULL,
    CONSTRAINT uq_formas_pagamento_descricao UNIQUE (descricao)
);

CREATE TABLE categorias_peca (
    categoria_peca_id  INT PRIMARY KEY,
    descricao          VARCHAR(80) NOT NULL,
    CONSTRAINT uq_categorias_peca_descricao UNIQUE (descricao)
);

CREATE TABLE fornecedores (
    fornecedor_id   INT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(20) NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    CONSTRAINT uq_fornecedores_cnpj UNIQUE (cnpj)
);

CREATE TABLE servicos (
    servico_id          INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    valor               DECIMAL(10,2) NOT NULL,
    tempo_estimado_min  INT
);

CREATE TABLE funcionarios (
    funcionario_id      INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    cpf                 VARCHAR(14) NOT NULL,
    telefone            VARCHAR(20),
    data_admissao       DATE NOT NULL,
    salario             DECIMAL(10,2) NOT NULL,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    tipo_funcionario_id INT NOT NULL,
    CONSTRAINT uq_funcionarios_cpf UNIQUE (cpf),
    CONSTRAINT fk_funcionarios_tipo
        FOREIGN KEY (tipo_funcionario_id)
        REFERENCES tipos_funcionario (tipo_funcionario_id)
        ON DELETE RESTRICT
);

CREATE TABLE veiculos (
    veiculo_id      INT PRIMARY KEY,
    placa           VARCHAR(10) NOT NULL,
    marca           VARCHAR(50) NOT NULL,
    modelo          VARCHAR(50) NOT NULL,
    ano_fabricacao  INT,
    ano_modelo      INT,
    cor             VARCHAR(30),
    quilometragem   INT,
    cliente_id      INT NOT NULL,
    CONSTRAINT uq_veiculos_placa UNIQUE (placa),
    CONSTRAINT fk_veiculos_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id)
        ON DELETE RESTRICT
);

CREATE TABLE pecas (
    peca_id             INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    preco_custo         DECIMAL(10,2) NOT NULL,
    preco_venda         DECIMAL(10,2) NOT NULL,
    unidade_medida      VARCHAR(10) NOT NULL,
    categoria_peca_id   INT NOT NULL,
    fornecedor_id       INT NOT NULL,
    CONSTRAINT fk_pecas_categoria
        FOREIGN KEY (categoria_peca_id)
        REFERENCES categorias_peca (categoria_peca_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pecas_fornecedor
        FOREIGN KEY (fornecedor_id)
        REFERENCES fornecedores (fornecedor_id)
        ON DELETE RESTRICT
);

CREATE TABLE ordens_servico (
    ordem_servico_id    INT PRIMARY KEY,
    cliente_id          INT NOT NULL,
    veiculo_id          INT NOT NULL,
    funcionario_id      INT NOT NULL,
    data_abertura       TIMESTAMP NOT NULL,
    data_previsao       DATE,
    data_conclusao      TIMESTAMP,
    status              VARCHAR(20) NOT NULL,
    valor_total         DECIMAL(10,2) NOT NULL DEFAULT 0,
    observacoes         VARCHAR(255),
    CONSTRAINT ck_ordens_servico_status
        CHECK (status IN ('ABERTA','EM_ANDAMENTO','CONCLUIDA','CANCELADA')),
    CONSTRAINT fk_ordens_servico_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_ordens_servico_veiculo
        FOREIGN KEY (veiculo_id)
        REFERENCES veiculos (veiculo_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_ordens_servico_funcionario
        FOREIGN KEY (funcionario_id)
        REFERENCES funcionarios (funcionario_id)
        ON DELETE RESTRICT
);

CREATE TABLE estoques (
    estoque_id          INT PRIMARY KEY,
    peca_id             INT NOT NULL,
    quantidade_atual    INT NOT NULL DEFAULT 0,
    quantidade_minima   INT NOT NULL DEFAULT 0,
    localizacao         VARCHAR(50),
    data_atualizacao    DATE,
    CONSTRAINT uq_estoques_peca UNIQUE (peca_id),
    CONSTRAINT fk_estoques_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE CASCADE
);

CREATE TABLE movimentacoes_estoque (
    movimentacao_estoque_id INT PRIMARY KEY,
    peca_id                 INT NOT NULL,
    tipo_movimentacao       VARCHAR(10) NOT NULL,
    quantidade              INT NOT NULL,
    data_movimentacao       TIMESTAMP NOT NULL,
    observacao              VARCHAR(255),
    CONSTRAINT ck_movimentacoes_tipo
        CHECK (tipo_movimentacao IN ('ENTRADA','SAIDA')),
    CONSTRAINT fk_movimentacoes_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE CASCADE
);

CREATE TABLE ordens_servico_pecas (
    ordem_servico_peca_id  INT PRIMARY KEY,
    ordem_servico_id       INT NOT NULL,
    peca_id                INT NOT NULL,
    quantidade             INT NOT NULL,
    preco_unitario         DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_osp_ordem_servico
        FOREIGN KEY (ordem_servico_id)
        REFERENCES ordens_servico (ordem_servico_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_osp_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE RESTRICT
);

CREATE TABLE ordens_servico_servicos (
    ordem_servico_servico_id   INT PRIMARY KEY,
    ordem_servico_id           INT NOT NULL,
    servico_id                 INT NOT NULL,
    funcionario_id              INT NOT NULL,
    valor_cobrado               DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_oss_ordem_servico
        FOREIGN KEY (ordem_servico_id)
        REFERENCES ordens_servico (ordem_servico_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_oss_servico
        FOREIGN KEY (servico_id)
        REFERENCES servicos (servico_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_oss_funcionario
        FOREIGN KEY (funcionario_id)
        REFERENCES funcionarios (funcionario_id)
        ON DELETE RESTRICT
);

CREATE TABLE pagamentos (
    pagamento_id        INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL,
    forma_pagamento_id  INT NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    data_pagamento      TIMESTAMP NOT NULL,
    parcelas            INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_pagamentos_ordem_servico
        FOREIGN KEY (ordem_servico_id)
        REFERENCES ordens_servico (ordem_servico_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pagamentos_forma
        FOREIGN KEY (forma_pagamento_id)
        REFERENCES formas_pagamento (forma_pagamento_id)
        ON DELETE RESTRICT
);


-- 3) popular as tabelas
INSERT INTO clientes (cliente_id, nome, cpf_cnpj, telefone, email, endereco, data_cadastro, ativo) VALUES
(1, 'Marcos Andrade', '754.214.125-45', '(71) 95012-4657', 'marcos.andrade@email.com', 'Rua Central, 764', '2023-04-15', TRUE),
(2, 'Juliana Ferreira', '658.189.704-64', '(71) 91520-1488', 'juliana.ferreira@email.com', 'Rua das Flores, 233', '2023-08-27', TRUE),
(3, 'Renato Souza', '127.674.303-93', '(71) 99928-7873', 'renato.souza@email.com', 'Rua Central, 469', '2024-08-26', TRUE),
(4, 'Camila Rocha', '990.106.877-30', '(71) 97924-6574', 'camila.rocha@email.com', 'Rua Nova, 169', '2023-08-09', TRUE),
(5, 'Bruno Teixeira', '444.204.194-58', '(71) 92584-6881', 'bruno.teixeira@email.com', 'Rua Nova, 628', '2023-09-28', TRUE),
(6, 'Larissa Pinto', '847.570.649-25', '(71) 97201-2291', 'larissa.pinto@email.com', 'Rua das Palmeiras, 310', '2025-04-29', TRUE),
(7, 'Diego Almeida', '982.470.691-34', '(71) 92139-1750', 'diego.almeida@email.com', 'Rua Central, 801', '2023-10-24', TRUE),
(8, 'Fernanda Castro', '975.338.987-22', '(71) 97227-5554', 'fernanda.castro@email.com', 'Rua do Comércio, 660', '2025-05-04', TRUE),
(9, 'Rodrigo Melo', '479.463.314-95', '(71) 95374-2169', 'rodrigo.melo@email.com', 'Rua das Palmeiras, 660', '2023-06-25', TRUE),
(10, 'Aline Barros', '350.267.573-58', '(71) 95422-4598', 'aline.barros@email.com', 'Rua Nova, 873', '2025-02-25', TRUE),
(11, 'Thiago Nascimento', '334.941.132-50', '(71) 97572-5386', 'thiago.nascimento@email.com', 'Rua das Flores, 226', '2024-08-03', TRUE),
(12, 'Patrícia Ramos', '422.317.771-73', '(71) 97482-8517', 'patrícia.ramos@email.com', 'Rua Central, 281', '2023-05-23', TRUE),
(13, 'Gustavo Farias', '674.651.369-84', '(71) 98019-7543', 'gustavo.farias@email.com', 'Rua Nova, 234', '2023-05-22', TRUE),
(14, 'Vanessa Lopes', '193.873.148-24', '(71) 93504-3621', 'vanessa.lopes@email.com', 'Rua do Comércio, 620', '2023-03-07', TRUE),
(15, 'André Cardoso', '710.579.641-42', '(71) 91188-2876', 'andré.cardoso@email.com', 'Rua das Palmeiras, 778', '2023-10-01', TRUE),
(16, 'Priscila Moura', '448.214.400-65', '(71) 93591-8433', 'priscila.moura@email.com', 'Rua das Flores, 986', '2025-01-09', TRUE),
(17, 'Leonardo Dias', '369.612.880-32', '(71) 99317-2743', 'leonardo.dias@email.com', 'Rua Nova, 871', '2024-10-16', TRUE),
(18, 'Simone Correia', '303.256.482-30', '(71) 99837-9689', 'simone.correia@email.com', 'Rua das Flores, 623', '2023-11-28', TRUE),
(19, 'Felipe Batista', '214.471.999-49', '(71) 94923-1949', 'felipe.batista@email.com', 'Rua Central, 909', '2024-08-03', TRUE),
(20, 'Débora Santana', '187.849.597-18', '(71) 99727-3060', 'débora.santana@email.com', 'Rua Central, 685', '2024-05-01', TRUE),
(21, 'Rafael Cunha', '269.371.640-87', '(71) 97932-4470', 'rafael.cunha@email.com', 'Rua das Palmeiras, 783', '2025-01-17', TRUE),
(22, 'Tatiane Vieira', '830.419.508-95', '(71) 97118-8177', 'tatiane.vieira@email.com', 'Rua das Palmeiras, 472', '2023-05-04', TRUE),
(23, 'Eduardo Monteiro', '165.446.121-85', '(71) 94770-4608', 'eduardo.monteiro@email.com', 'Rua das Flores, 82', '2024-12-25', TRUE),
(24, 'Cristiane Freitas', '334.169.132-52', '(71) 92160-9423', 'cristiane.freitas@email.com', 'Rua Central, 295', '2024-11-16', TRUE),
(25, 'Marcelo Aragão', '652.235.840-83', '(71) 98744-4981', 'marcelo.aragão@email.com', 'Rua do Comércio, 836', '2024-02-21', TRUE),
(26, 'Comercial Sol Ltda', '22.774.541/0001-55', '(71) 3533-7735', 'contato@comercial.com.br', 'Av. Portuária, 984', '2025-01-16', TRUE),
(27, 'Transportes Bahia Norte', '16.789.769/0001-92', '(71) 3200-1993', 'contato@transportes.com.br', 'Av. Portuária, 845', '2023-12-14', TRUE),
(28, 'Distribuidora Litoral ME', '23.354.296/0001-34', '(71) 3649-8350', 'contato@distribuidora.com.br', 'Av. Industrial, 532', '2023-07-07', TRUE),
(29, 'Auto Locadora Central', '45.573.355/0001-19', '(71) 3553-2604', 'contato@auto.com.br', 'Av. Industrial, 767', '2024-07-07', TRUE),
(30, 'Construtora Vale Verde', '11.195.871/0001-40', '(71) 3270-7658', 'contato@construtora.com.br', 'Av. Portuária, 592', '2023-08-07', TRUE);

INSERT INTO veiculos (veiculo_id, placa, marca, modelo, ano_fabricacao, ano_modelo, cor, quilometragem, cliente_id) VALUES
(1, 'WXE1035', 'Fiat', 'Uno', 2018, 2018, 'Cinza', 79776, 1),
(2, 'KYZ8973', 'Fiat', 'Palio', 2014, 2014, 'Prata', 62068, 2),
(3, 'ZPO6138', 'Fiat', 'Argo', 2012, 2012, 'Vermelho', 129987, 3),
(4, 'NWE9320', 'Chevrolet', 'Onix', 2013, 2013, 'Branco', 22815, 4),
(5, 'RGD5033', 'Chevrolet', 'Celta', 2021, 2022, 'Branco', 26491, 5),
(6, 'KPN5272', 'Chevrolet', 'S10', 2015, 2016, 'Azul', 87361, 6),
(7, 'GKR5915', 'Volkswagen', 'Gol', 2019, 2019, 'Branco', 7441, 7),
(8, 'LZZ2200', 'Volkswagen', 'Voyage', 2020, 2020, 'Vermelho', 74520, 8),
(9, 'DJB5002', 'Volkswagen', 'Saveiro', 2017, 2017, 'Preto', 119867, 9),
(10, 'VSP9666', 'Ford', 'Ranger', 2012, 2013, 'Vermelho', 83480, 10),
(11, 'YCW5333', 'Ford', 'Ka', 2013, 2013, 'Azul', 45749, 11),
(12, 'HPS4335', 'Ford', 'Fiesta', 2022, 2023, 'Prata', 137489, 12),
(13, 'MXV2512', 'Honda', 'Civic', 2022, 2022, 'Prata', 16557, 13),
(14, 'AUQ5291', 'Honda', 'Fit', 2014, 2015, 'Cinza', 149619, 14),
(15, 'SOC3442', 'Toyota', 'Corolla', 2020, 2020, 'Prata', 149841, 15),
(16, 'DDI1653', 'Toyota', 'Hilux', 2017, 2017, 'Azul', 70412, 16),
(17, 'RJO7658', 'Hyundai', 'HB20', 2021, 2022, 'Preto', 67059, 17),
(18, 'WZV7755', 'Renault', 'Sandero', 2012, 2012, 'Azul', 92080, 18),
(19, 'UKR5065', 'Renault', 'Duster', 2016, 2016, 'Azul', 33336, 19),
(20, 'JBM4269', 'Jeep', 'Renegade', 2019, 2019, 'Prata', 64662, 20),
(21, 'FRK5564', 'Nissan', 'Kicks', 2013, 2013, 'Prata', 138537, 21),
(22, 'KZN1452', 'Peugeot', '208', 2013, 2013, 'Preto', 74590, 22),
(23, 'API6139', 'Fiat', 'Uno', 2018, 2019, 'Vermelho', 35315, 23),
(24, 'KOG8144', 'Fiat', 'Palio', 2012, 2013, 'Vermelho', 56651, 24),
(25, 'JBR6409', 'Fiat', 'Argo', 2021, 2021, 'Azul', 37669, 25),
(26, 'SHI7691', 'Chevrolet', 'Onix', 2017, 2017, 'Azul', 82504, 26),
(27, 'OER7211', 'Chevrolet', 'Celta', 2022, 2023, 'Preto', 83892, 27),
(28, 'KVH4443', 'Chevrolet', 'S10', 2018, 2019, 'Vermelho', 89475, 28),
(29, 'MLF8752', 'Volkswagen', 'Gol', 2024, 2025, 'Preto', 27228, 29),
(30, 'HRQ2530', 'Volkswagen', 'Voyage', 2024, 2024, 'Azul', 86374, 30),
(31, 'FFA5011', 'Volkswagen', 'Saveiro', 2019, 2020, 'Branco', 124384, 1),
(32, 'KQF7291', 'Ford', 'Ranger', 2019, 2019, 'Preto', 43684, 2);

INSERT INTO tipos_funcionario (tipo_funcionario_id, descricao) VALUES
(1, 'Mecânico'),
(2, 'Atendente'),
(3, 'Gerente'),
(4, 'Caixa'),
(5, 'Auxiliar de Estoque');

INSERT INTO funcionarios (funcionario_id, nome, cpf, telefone, data_admissao, salario, ativo, tipo_funcionario_id) VALUES
(1, 'Carlos Lima', '771.804.105-23', '(71) 97965-4585', '2020-12-21', 3847.40, TRUE, 1),
(2, 'Fernanda Alves', '575.151.670-41', '(71) 92988-8478', '2020-06-30', 2621.27, TRUE, 2),
(3, 'Roberto Nunes', '672.709.424-66', '(71) 99270-7991', '2025-02-22', 5409.39, TRUE, 4),
(4, 'Patrícia Gomes', '586.560.365-41', '(71) 95543-9540', '2024-06-07', 3528.15, TRUE, 1),
(5, 'Wesley Nogueira', '179.830.392-40', '(71) 95451-6502', '2022-08-02', 2703.72, TRUE, 2),
(6, 'Adriana Peixoto', '254.336.492-98', '(71) 93503-4505', '2019-09-21', 3548.88, TRUE, 4),
(7, 'Luiz Fernando Costa', '525.163.311-63', '(71) 97381-1320', '2025-06-16', 3084.69, FALSE, 1),
(8, 'Sandra Regina Dias', '460.405.871-59', '(71) 97865-9818', '2025-02-14', 2619.88, TRUE, 2),
(9, 'João Paulo Reis', '599.324.379-65', '(71) 98956-1475', '2023-05-12', 4541.72, TRUE, 4),
(10, 'Marina Duarte', '841.269.960-69', '(71) 93091-9751', '2019-04-21', 4032.47, TRUE, 1),
(11, 'Ricardo Bittencourt', '778.127.185-92', '(71) 98022-3223', '2024-03-06', 2063.56, TRUE, 2),
(12, 'Elaine Cristina Souza', '435.316.565-51', '(71) 96529-7211', '2022-02-13', 2958.63, TRUE, 4),
(13, 'Fábio Henrique Lopes', '119.867.652-16', '(71) 96733-4673', '2019-10-09', 3806.22, TRUE, 1),
(14, 'Rosana Andrade', '872.131.353-35', '(71) 91333-3496', '2021-09-04', 2013.60, TRUE, 2),
(15, 'Vinícius Torres', '677.323.576-99', '(71) 95198-7043', '2020-11-18', 4307.54, TRUE, 5),
(16, 'Mariana Coutinho', '217.896.938-30', '(71) 96096-2771', '2025-06-28', 2446.22, TRUE, 1),
(17, 'Alexandre Vidal', '793.484.506-35', '(71) 92245-4978', '2020-02-22', 2527.47, TRUE, 2),
(18, 'Bianca Ferraz', '800.714.924-25', '(71) 91672-6688', '2024-12-22', 4513.78, FALSE, 4),
(19, 'Gilberto Machado', '763.449.112-63', '(71) 99031-2729', '2023-11-11', 4129.42, TRUE, 1),
(20, 'Cíntia Rezende', '948.570.824-29', '(71) 98135-3885', '2024-11-07', 2768.93, TRUE, 2),
(21, 'Anderson Prado', '927.651.893-71', '(71) 98616-8136', '2022-01-04', 5236.51, TRUE, 4),
(22, 'Kelly Cristina Matos', '188.385.561-41', '(71) 98613-7209', '2022-10-09', 2451.66, TRUE, 1),
(23, 'Sérgio Barbosa', '286.599.317-55', '(71) 95232-6576', '2022-02-19', 2692.29, TRUE, 2),
(24, 'Viviane Cardoso', '382.669.110-76', '(71) 94130-2402', '2021-09-15', 3544.43, TRUE, 5),
(25, 'Douglas Emanuel Silva', '346.807.587-92', '(71) 99041-8342', '2019-03-12', 2567.50, TRUE, 1),
(26, 'Tânia Mara Oliveira', '808.349.413-94', '(71) 97046-8753', '2025-03-17', 2377.83, TRUE, 2),
(27, 'Nelson Augusto Ribeiro', '863.663.438-55', '(71) 98434-5438', '2022-06-09', 2876.04, TRUE, 4),
(28, 'Michele Fontes', '423.222.860-78', '(71) 94033-4138', '2021-06-05', 3729.49, TRUE, 1),
(29, 'Otávio Guedes', '703.878.637-86', '(71) 95636-2647', '2021-03-06', 2166.62, TRUE, 2),
(30, 'Rejane Farias', '409.114.825-78', '(71) 93073-5494', '2019-07-06', 4102.76, TRUE, 3);

INSERT INTO fornecedores (fornecedor_id, razao_social, cnpj, telefone, email, endereco) VALUES
(1, 'AutoPeças Bahia Ltda', '22.333.444/0001-55', '(71) 3200-1000', 'vendas@autopecasbahia.com.br', 'Av. Industrial, 500'),
(2, 'Distribuidora Motor Sul', '33.444.555/0001-66', '(71) 3200-2000', 'comercial@motorsul.com.br', 'Rua das Oficinas, 300'),
(3, 'Peças & Cia Nordeste', '44.555.666/0001-77', '(71) 3200-3000', 'contato@pecasecia.com.br', 'Rod. BA-093, km 12'),
(4, 'Grupo AutoPart Brasil', '55.666.777/0001-88', '(71) 3200-4000', 'vendas@autopartbrasil.com.br', 'Av. das Indústrias, 1200');

INSERT INTO categorias_peca (categoria_peca_id, descricao) VALUES
(1, 'Motor'),
(2, 'Freios'),
(3, 'Suspensão'),
(4, 'Elétrica'),
(5, 'Filtros e Fluidos'),
(6, 'Arrefecimento'),
(7, 'Transmissão'),
(8, 'Carroceria');

INSERT INTO pecas (peca_id, nome, descricao, preco_custo, preco_venda, unidade_medida, categoria_peca_id, fornecedor_id) VALUES
(1, 'Óleo de Motor 5W30 (1L)', 'Óleo sintético', 18.00, 32.00, 'UN', 5, 1),
(2, 'Óleo de Motor 20W50 (1L)', 'Óleo mineral', 12.00, 22.00, 'UN', 5, 2),
(3, 'Filtro de Óleo', 'Filtro de óleo padrão', 8.00, 18.00, 'UN', 5, 3),
(4, 'Filtro de Ar', 'Filtro de ar do motor', 15.00, 29.00, 'UN', 5, 4),
(5, 'Filtro de Combustível', 'Filtro de combustível', 20.00, 38.00, 'UN', 5, 1),
(6, 'Filtro de Cabine', 'Filtro de ar-condicionado', 22.00, 42.00, 'UN', 5, 2),
(7, 'Pastilha de Freio Dianteira', 'Jogo de pastilhas', 45.00, 89.00, 'JG', 2, 3),
(8, 'Pastilha de Freio Traseira', 'Jogo de pastilhas', 40.00, 79.00, 'JG', 2, 4),
(9, 'Disco de Freio Dianteiro', 'Disco ventilado', 95.00, 175.00, 'UN', 2, 1),
(10, 'Fluido de Freio DOT4', 'Fluido hidráulico', 14.00, 26.00, 'UN', 2, 2),
(11, 'Amortecedor Dianteiro', 'Amortecedor a gás', 120.00, 210.00, 'UN', 3, 3),
(12, 'Amortecedor Traseiro', 'Amortecedor a gás', 110.00, 195.00, 'UN', 3, 4),
(13, 'Mola Helicoidal', 'Mola de suspensão', 70.00, 130.00, 'UN', 3, 1),
(14, 'Bieleta de Suspensão', 'Bieleta dianteira', 25.00, 48.00, 'UN', 3, 2),
(15, 'Bateria 60Ah', 'Bateria automotiva', 280.00, 420.00, 'UN', 4, 3),
(16, 'Bateria 45Ah', 'Bateria automotiva', 220.00, 350.00, 'UN', 4, 4),
(17, 'Vela de Ignição', 'Jogo com 4 velas', 30.00, 58.00, 'JG', 4, 1),
(18, 'Alternador', 'Alternador recondicionado', 250.00, 420.00, 'UN', 4, 2),
(19, 'Motor de Arranque', 'Motor de partida', 230.00, 390.00, 'UN', 4, 3),
(20, 'Correia Dentada', 'Kit correia dentada', 90.00, 160.00, 'JG', 1, 4),
(21, 'Correia Alternador', 'Correia em V', 25.00, 45.00, 'UN', 1, 1),
(22, 'Junta do Cabeçote', 'Junta de vedação', 60.00, 110.00, 'UN', 1, 2),
(23, 'Kit Embreagem', 'Kit platô/disco/rolamento', 280.00, 480.00, 'JG', 7, 3),
(24, 'Óleo de Câmbio', 'Óleo para câmbio manual', 25.00, 45.00, 'UN', 7, 4),
(25, 'Radiador', 'Radiador de arrefecimento', 180.00, 320.00, 'UN', 6, 1),
(26, 'Válvula Termostática', 'Válvula de arrefecimento', 35.00, 65.00, 'UN', 6, 2),
(27, 'Aditivo de Radiador', 'Aditivo concentrado', 18.00, 32.00, 'UN', 6, 3),
(28, 'Mangueira do Radiador', 'Mangueira superior', 20.00, 38.00, 'UN', 6, 4),
(29, 'Para-choque Dianteiro', 'Para-choque em plástico', 180.00, 340.00, 'UN', 8, 1),
(30, 'Retrovisor Externo', 'Retrovisor elétrico', 90.00, 165.00, 'UN', 8, 2),
(31, 'Lâmpada Farol H4', 'Lâmpada halógena', 10.00, 20.00, 'UN', 4, 3),
(32, 'Palheta Limpador de Para-brisa', 'Jogo de palhetas', 22.00, 40.00, 'JG', 8, 4);

INSERT INTO estoques (estoque_id, peca_id, quantidade_atual, quantidade_minima, localizacao, data_atualizacao) VALUES
(1, 1, 40, 5, 'Prateleira A1', '2026-08-27'),
(2, 2, 55, 5, 'Prateleira A2', '2026-08-14'),
(3, 3, 30, 8, 'Prateleira B1', '2026-08-12'),
(4, 4, 16, 5, 'Prateleira B2', '2026-08-27'),
(5, 5, 52, 5, 'Prateleira C1', '2026-08-17'),
(6, 6, 36, 5, 'Prateleira D1', '2026-08-20'),
(7, 7, 9, 5, 'Prateleira A1', '2026-08-24'),
(8, 8, 15, 5, 'Prateleira A2', '2026-08-16'),
(9, 9, 38, 10, 'Prateleira B1', '2026-08-23'),
(10, 10, 24, 10, 'Prateleira B2', '2026-08-17'),
(11, 11, 55, 8, 'Prateleira C1', '2026-08-26'),
(12, 12, 36, 8, 'Prateleira D1', '2026-08-29'),
(13, 13, 6, 10, 'Prateleira A1', '2026-08-23'),
(14, 14, 13, 10, 'Prateleira A2', '2026-08-11'),
(15, 15, 15, 5, 'Prateleira B1', '2026-08-11'),
(16, 16, 0, 5, 'Prateleira B2', '2026-08-19'),
(17, 17, 18, 8, 'Prateleira C1', '2026-08-14'),
(18, 18, 18, 10, 'Prateleira D1', '2026-08-27'),
(19, 19, 43, 5, 'Prateleira A1', '2026-08-14'),
(20, 20, 37, 10, 'Prateleira A2', '2026-08-23'),
(21, 21, 7, 8, 'Prateleira B1', '2026-08-22'),
(22, 22, 52, 8, 'Prateleira B2', '2026-08-10'),
(23, 23, 50, 5, 'Prateleira C1', '2026-08-19'),
(24, 24, 28, 8, 'Prateleira D1', '2026-08-14'),
(25, 25, 25, 10, 'Prateleira A1', '2026-08-28'),
(26, 26, 31, 10, 'Prateleira A2', '2026-08-19'),
(27, 27, 56, 5, 'Prateleira B1', '2026-08-15'),
(28, 28, 16, 10, 'Prateleira B2', '2026-08-13'),
(29, 29, 53, 10, 'Prateleira C1', '2026-08-29'),
(30, 30, 48, 5, 'Prateleira D1', '2026-08-24'),
(31, 31, 2, 10, 'Prateleira A1', '2026-08-22'),
(32, 32, 33, 8, 'Prateleira A2', '2026-08-24');

INSERT INTO movimentacoes_estoque (movimentacao_estoque_id, peca_id, tipo_movimentacao, quantidade, data_movimentacao, observacao) VALUES
(1, 1, 'ENTRADA', 6, '2026-08-25 17:00:00', 'Compra de fornecedor'),
(2, 2, 'SAIDA', 16, '2026-07-12 14:00:00', 'Uso em ordem de serviço'),
(3, 3, 'SAIDA', 12, '2026-08-22 12:00:00', 'Uso em ordem de serviço'),
(4, 4, 'ENTRADA', 11, '2026-07-14 09:00:00', 'Compra de fornecedor'),
(5, 5, 'SAIDA', 11, '2026-08-22 18:00:00', 'Uso em ordem de serviço'),
(6, 6, 'SAIDA', 16, '2026-08-06 17:00:00', 'Uso em ordem de serviço'),
(7, 7, 'ENTRADA', 13, '2026-07-05 14:00:00', 'Compra de fornecedor'),
(8, 8, 'SAIDA', 3, '2026-08-10 11:00:00', 'Uso em ordem de serviço'),
(9, 9, 'SAIDA', 11, '2026-07-15 13:00:00', 'Uso em ordem de serviço'),
(10, 10, 'ENTRADA', 17, '2026-07-01 17:00:00', 'Compra de fornecedor'),
(11, 11, 'SAIDA', 18, '2026-08-29 13:00:00', 'Uso em ordem de serviço'),
(12, 12, 'SAIDA', 2, '2026-07-25 15:00:00', 'Uso em ordem de serviço'),
(13, 13, 'ENTRADA', 12, '2026-09-02 17:00:00', 'Compra de fornecedor'),
(14, 14, 'SAIDA', 15, '2026-07-07 10:00:00', 'Uso em ordem de serviço'),
(15, 15, 'SAIDA', 9, '2026-07-17 11:00:00', 'Uso em ordem de serviço'),
(16, 16, 'ENTRADA', 15, '2026-09-01 08:00:00', 'Compra de fornecedor'),
(17, 17, 'SAIDA', 1, '2026-07-31 18:00:00', 'Uso em ordem de serviço'),
(18, 18, 'SAIDA', 6, '2026-08-09 15:00:00', 'Uso em ordem de serviço'),
(19, 19, 'ENTRADA', 1, '2026-08-22 08:00:00', 'Compra de fornecedor'),
(20, 20, 'SAIDA', 8, '2026-07-15 14:00:00', 'Uso em ordem de serviço'),
(21, 21, 'SAIDA', 4, '2026-07-20 14:00:00', 'Uso em ordem de serviço'),
(22, 22, 'ENTRADA', 10, '2026-09-04 18:00:00', 'Compra de fornecedor'),
(23, 23, 'SAIDA', 9, '2026-08-23 14:00:00', 'Uso em ordem de serviço'),
(24, 24, 'SAIDA', 16, '2026-08-01 14:00:00', 'Uso em ordem de serviço'),
(25, 25, 'ENTRADA', 18, '2026-07-19 13:00:00', 'Compra de fornecedor'),
(26, 26, 'SAIDA', 7, '2026-09-04 18:00:00', 'Uso em ordem de serviço'),
(27, 27, 'SAIDA', 5, '2026-07-09 11:00:00', 'Uso em ordem de serviço'),
(28, 28, 'ENTRADA', 14, '2026-08-13 15:00:00', 'Compra de fornecedor'),
(29, 29, 'SAIDA', 9, '2026-07-01 11:00:00', 'Uso em ordem de serviço'),
(30, 30, 'SAIDA', 10, '2026-09-01 09:00:00', 'Uso em ordem de serviço'),
(31, 31, 'ENTRADA', 15, '2026-08-31 12:00:00', 'Compra de fornecedor'),
(32, 32, 'SAIDA', 11, '2026-08-18 14:00:00', 'Uso em ordem de serviço'),
(33, 1, 'SAIDA', 11, '2026-07-25 18:00:00', 'Uso em ordem de serviço'),
(34, 2, 'ENTRADA', 8, '2026-08-19 10:00:00', 'Compra de fornecedor'),
(35, 3, 'SAIDA', 14, '2026-07-06 12:00:00', 'Uso em ordem de serviço'),
(36, 4, 'SAIDA', 16, '2026-08-18 13:00:00', 'Uso em ordem de serviço');

INSERT INTO servicos (servico_id, nome, descricao, valor, tempo_estimado_min) VALUES
(1, 'Troca de Óleo', 'Troca de óleo e filtro', 80.00, 40),
(2, 'Alinhamento e Balanceamento', 'Alinhamento de direção e balanceamento', 120.00, 60),
(3, 'Revisão de Freios', 'Verificação e troca de pastilhas', 150.00, 90),
(4, 'Troca de Bateria', 'Substituição da bateria', 50.00, 20),
(5, 'Troca de Correia Dentada', 'Substituição do kit de correia', 280.00, 120),
(6, 'Troca de Amortecedores', 'Substituição de amortecedores (par)', 220.00, 100),
(7, 'Diagnóstico Eletrônico', 'Leitura de códigos de falha via scanner', 70.00, 30),
(8, 'Troca de Vela de Ignição', 'Substituição do jogo de velas', 90.00, 40),
(9, 'Higienização do Ar-condicionado', 'Limpeza e troca de filtro de cabine', 130.00, 50),
(10, 'Troca de Radiador', 'Substituição do radiador', 300.00, 120),
(11, 'Reparo no Sistema de Freios', 'Troca de disco e pastilha', 250.00, 100),
(12, 'Troca de Embreagem', 'Substituição do kit de embreagem', 450.00, 180),
(13, 'Revisão Geral', 'Checklist completo do veículo', 180.00, 90),
(14, 'Troca de Óleo de Câmbio', 'Substituição do óleo do câmbio', 100.00, 45),
(15, 'Reparo Elétrico', 'Diagnóstico e reparo elétrico', 160.00, 80),
(16, 'Troca de Alternador', 'Substituição do alternador', 280.00, 90),
(17, 'Troca de Motor de Arranque', 'Substituição do motor de partida', 260.00, 90),
(18, 'Balanceamento de Rodas', 'Balanceamento das 4 rodas', 60.00, 30),
(19, 'Cambagem e Geometria', 'Ajuste de geometria da suspensão', 140.00, 70),
(20, 'Troca de Correia do Alternador', 'Substituição da correia em V', 60.00, 30),
(21, 'Reparo de Suspensão', 'Troca de bieletas e buchas', 190.00, 100),
(22, 'Troca de Mangueiras', 'Substituição de mangueiras do sistema de arrefecimento', 90.00, 45),
(23, 'Lavagem Técnica de Motor', 'Limpeza detalhada do compartimento do motor', 90.00, 50),
(24, 'Troca de Para-brisa', 'Substituição do para-brisa', 350.00, 100),
(25, 'Reparo de Ar-condicionado', 'Recarga e reparo do sistema', 160.00, 70),
(26, 'Troca de Retrovisor', 'Substituição de retrovisor externo', 120.00, 40),
(27, 'Polimento e Cristalização', 'Estética automotiva', 250.00, 150),
(28, 'Troca de Palhetas', 'Substituição das palhetas do limpador', 30.00, 15),
(29, 'Instalação de Som Automotivo', 'Instalação de multimídia', 180.00, 90),
(30, 'Revisão de Suspensão Completa', 'Revisão de todos os componentes da suspensão', 320.00, 150);

INSERT INTO formas_pagamento (forma_pagamento_id, descricao) VALUES
(1, 'Dinheiro'),
(2, 'Pix'),
(3, 'Cartão de Débito'),
(4, 'Cartão de Crédito'),
(5, 'Boleto');

INSERT INTO ordens_servico (ordem_servico_id, cliente_id, veiculo_id, funcionario_id, data_abertura, data_previsao, data_conclusao, status, valor_total, observacoes) VALUES
(1, 1, 1, 7, '2026-09-02 07:00:00', '2026-09-02', NULL, 'ABERTA', 390.00, NULL),
(2, 2, 2, 25, '2026-08-12 08:00:00', '2026-08-13', NULL, 'EM_ANDAMENTO', 206.00, NULL),
(3, 3, 3, 4, '2026-09-06 14:00:00', '2026-09-06', '2026-09-06 20:00:00', 'CONCLUIDA', 349.00, NULL),
(4, 4, 4, 7, '2026-08-22 17:00:00', '2026-08-22', NULL, 'CANCELADA', 833.00, NULL),
(5, 5, 5, 4, '2026-08-30 11:00:00', '2026-08-31', NULL, 'ABERTA', 1123.00, NULL),
(6, 6, 6, 28, '2026-08-20 17:00:00', '2026-08-20', NULL, 'EM_ANDAMENTO', 391.00, NULL),
(7, 7, 7, 16, '2026-09-07 13:00:00', '2026-09-08', '2026-09-07 19:00:00', 'CONCLUIDA', 934.00, NULL),
(8, 8, 8, 22, '2026-07-05 16:00:00', '2026-07-05', NULL, 'CANCELADA', 78.00, NULL),
(9, 9, 9, 10, '2026-08-06 10:00:00', '2026-08-08', NULL, 'ABERTA', 200.00, NULL),
(10, 10, 10, 4, '2026-08-25 08:00:00', '2026-08-27', NULL, 'EM_ANDAMENTO', 150.00, NULL),
(11, 11, 11, 4, '2026-08-26 09:00:00', '2026-08-28', '2026-08-26 12:00:00', 'CONCLUIDA', 450.00, NULL),
(12, 12, 12, 1, '2026-07-06 12:00:00', '2026-07-06', NULL, 'CANCELADA', 331.00, NULL),
(13, 13, 13, 13, '2026-08-15 12:00:00', '2026-08-16', NULL, 'ABERTA', 506.00, NULL),
(14, 14, 14, 7, '2026-08-01 15:00:00', '2026-08-02', NULL, 'EM_ANDAMENTO', 354.00, NULL),
(15, 15, 15, 28, '2026-07-24 09:00:00', '2026-07-24', '2026-07-24 10:00:00', 'CONCLUIDA', 676.00, NULL),
(16, 16, 16, 28, '2026-08-18 16:00:00', '2026-08-20', NULL, 'CANCELADA', 635.00, NULL),
(17, 17, 17, 10, '2026-09-02 16:00:00', '2026-09-02', NULL, 'ABERTA', 580.00, NULL),
(18, 18, 18, 10, '2026-08-29 17:00:00', '2026-08-30', NULL, 'EM_ANDAMENTO', 1480.00, NULL),
(19, 19, 19, 22, '2026-08-02 17:00:00', '2026-08-02', '2026-08-02 21:00:00', 'CONCLUIDA', 140.00, NULL),
(20, 20, 20, 13, '2026-07-21 08:00:00', '2026-07-22', NULL, 'CANCELADA', 487.00, NULL),
(21, 21, 21, 16, '2026-08-08 17:00:00', '2026-08-09', NULL, 'ABERTA', 212.00, NULL),
(22, 22, 22, 13, '2026-08-28 11:00:00', '2026-08-28', NULL, 'EM_ANDAMENTO', 936.00, NULL),
(23, 23, 23, 19, '2026-08-31 08:00:00', '2026-08-31', '2026-08-31 12:00:00', 'CONCLUIDA', 502.00, NULL),
(24, 24, 24, 28, '2026-08-15 16:00:00', '2026-08-16', NULL, 'CANCELADA', 993.00, NULL),
(25, 25, 25, 13, '2026-07-03 17:00:00', '2026-07-04', NULL, 'ABERTA', 450.00, NULL),
(26, 26, 26, 13, '2026-07-02 16:00:00', '2026-07-04', NULL, 'EM_ANDAMENTO', 114.00, NULL),
(27, 27, 27, 1, '2026-09-02 11:00:00', '2026-09-02', '2026-09-02 16:00:00', 'CONCLUIDA', 255.00, NULL),
(28, 28, 28, 16, '2026-07-29 17:00:00', '2026-07-29', NULL, 'CANCELADA', 208.00, NULL),
(29, 29, 29, 28, '2026-08-02 17:00:00', '2026-08-04', NULL, 'ABERTA', 506.00, NULL),
(30, 30, 30, 7, '2026-07-13 17:00:00', '2026-07-15', NULL, 'EM_ANDAMENTO', 130.00, NULL),
(31, 1, 31, 1, '2026-08-09 14:00:00', '2026-08-09', '2026-08-09 20:00:00', 'CONCLUIDA', 1606.00, NULL),
(32, 2, 32, 7, '2026-07-12 11:00:00', '2026-07-13', NULL, 'CANCELADA', 30.00, NULL),
(33, 1, 1, 7, '2026-07-26 09:00:00', '2026-07-28', '2026-07-26 14:00:00', 'CONCLUIDA', 1584.00, NULL),
(34, 2, 2, 25, '2026-08-04 09:00:00', '2026-08-05', NULL, 'CANCELADA', 915.00, NULL);

INSERT INTO ordens_servico_pecas (ordem_servico_peca_id, ordem_servico_id, peca_id, quantidade, preco_unitario) VALUES
(1, 1, 22, 1, 110.00),
(2, 2, 5, 1, 38.00),
(3, 2, 10, 3, 26.00),
(4, 3, 26, 2, 65.00),
(5, 3, 24, 1, 45.00),
(6, 3, 6, 2, 42.00),
(7, 4, 8, 2, 79.00),
(8, 4, 30, 3, 165.00),
(9, 5, 17, 1, 58.00),
(10, 5, 25, 3, 320.00),
(11, 5, 24, 1, 45.00),
(12, 6, 2, 3, 22.00),
(13, 6, 21, 1, 45.00),
(14, 7, 5, 3, 38.00),
(15, 7, 30, 2, 165.00),
(16, 7, 20, 1, 160.00),
(17, 8, 3, 1, 18.00),
(18, 9, 32, 1, 40.00),
(19, 11, 9, 2, 175.00),
(20, 12, 24, 3, 45.00),
(21, 12, 27, 3, 32.00),
(22, 13, 10, 2, 26.00),
(23, 13, 27, 3, 32.00),
(24, 13, 7, 2, 89.00),
(25, 14, 3, 3, 18.00),
(26, 15, 14, 2, 48.00),
(27, 16, 16, 1, 350.00),
(28, 16, 24, 3, 45.00),
(29, 17, 23, 1, 480.00),
(30, 18, 18, 1, 420.00),
(31, 18, 13, 2, 130.00),
(32, 20, 14, 2, 48.00),
(33, 20, 2, 1, 22.00),
(34, 20, 4, 1, 29.00),
(35, 21, 14, 3, 48.00),
(36, 21, 5, 1, 38.00),
(37, 22, 14, 2, 48.00),
(38, 22, 15, 1, 420.00),
(39, 23, 1, 1, 32.00),
(40, 23, 18, 1, 420.00),
(41, 24, 17, 1, 58.00),
(42, 24, 12, 3, 195.00),
(43, 26, 1, 2, 32.00),
(44, 27, 21, 1, 45.00),
(45, 28, 17, 1, 58.00),
(46, 29, 27, 3, 32.00),
(47, 31, 5, 2, 38.00),
(48, 31, 31, 3, 20.00),
(49, 31, 29, 3, 340.00),
(50, 33, 15, 3, 420.00),
(51, 33, 3, 3, 18.00),
(52, 34, 20, 3, 160.00),
(53, 34, 30, 1, 165.00);

INSERT INTO ordens_servico_servicos (ordem_servico_servico_id, ordem_servico_id, servico_id, funcionario_id, valor_cobrado) VALUES
(1, 1, 16, 19, 280.00),
(2, 2, 22, 4, 90.00),
(3, 3, 23, 22, 90.00),
(4, 4, 29, 4, 180.00),
(5, 5, 20, 7, 60.00),
(6, 6, 5, 13, 280.00),
(7, 7, 21, 25, 190.00),
(8, 7, 19, 16, 140.00),
(9, 8, 20, 25, 60.00),
(10, 9, 15, 25, 160.00),
(11, 10, 14, 4, 100.00),
(12, 10, 4, 25, 50.00),
(13, 11, 28, 19, 30.00),
(14, 11, 7, 22, 70.00),
(15, 12, 14, 16, 100.00),
(16, 13, 13, 19, 180.00),
(17, 14, 4, 19, 50.00),
(18, 14, 11, 16, 250.00),
(19, 15, 9, 7, 130.00),
(20, 15, 12, 22, 450.00),
(21, 16, 3, 4, 150.00),
(22, 17, 14, 4, 100.00),
(23, 18, 24, 7, 350.00),
(24, 18, 12, 25, 450.00),
(25, 19, 19, 25, 140.00),
(26, 20, 11, 4, 250.00),
(27, 20, 22, 19, 90.00),
(28, 21, 28, 19, 30.00),
(29, 22, 2, 28, 120.00),
(30, 22, 10, 13, 300.00),
(31, 23, 4, 28, 50.00),
(32, 24, 7, 22, 70.00),
(33, 24, 5, 10, 280.00),
(34, 25, 12, 25, 450.00),
(35, 26, 4, 13, 50.00),
(36, 27, 8, 19, 90.00),
(37, 27, 26, 25, 120.00),
(38, 28, 20, 25, 60.00),
(39, 28, 22, 1, 90.00),
(40, 29, 30, 13, 320.00),
(41, 29, 22, 1, 90.00),
(42, 30, 9, 13, 130.00),
(43, 31, 12, 1, 450.00),
(44, 32, 28, 7, 30.00),
(45, 33, 22, 4, 90.00),
(46, 33, 13, 7, 180.00),
(47, 34, 21, 4, 190.00),
(48, 34, 1, 25, 80.00);

INSERT INTO pagamentos (pagamento_id, ordem_servico_id, forma_pagamento_id, valor, data_pagamento, parcelas) VALUES
(1, 3, 2, 349.00, '2026-09-06 14:00:00', 1),
(2, 7, 4, 934.00, '2026-09-07 13:00:00', 2),
(3, 11, 4, 450.00, '2026-08-26 09:00:00', 1),
(4, 15, 2, 676.00, '2026-07-24 09:00:00', 1),
(5, 19, 3, 140.00, '2026-08-02 17:00:00', 1),
(6, 23, 3, 502.00, '2026-08-31 08:00:00', 1),
(7, 27, 3, 255.00, '2026-09-02 11:00:00', 1),
(8, 31, 5, 1606.00, '2026-08-09 14:00:00', 1),
(9, 33, 5, 1584.00, '2026-07-26 09:00:00', 1),
(10, 1, 1, 358.15, '2026-09-02 07:00:00', 1),
(11, 2, 2, 84.50, '2026-08-12 08:00:00', 1),
(12, 4, 5, 278.92, '2026-08-22 17:00:00', 1),
(13, 5, 1, 550.80, '2026-08-30 11:00:00', 1),
(14, 6, 4, 250.23, '2026-08-20 17:00:00', 1),
(15, 8, 4, 46.01, '2026-07-05 16:00:00', 1),
(16, 9, 2, 165.69, '2026-08-06 10:00:00', 1),
(17, 10, 1, 81.24, '2026-08-25 08:00:00', 1),
(18, 12, 1, 164.93, '2026-07-06 12:00:00', 1),
(19, 13, 5, 324.17, '2026-08-15 12:00:00', 1),
(20, 14, 3, 117.45, '2026-08-01 15:00:00', 1),
(21, 16, 4, 628.09, '2026-08-18 16:00:00', 1),
(22, 17, 1, 177.12, '2026-09-02 16:00:00', 1),
(23, 18, 3, 1423.36, '2026-08-29 17:00:00', 1),
(24, 20, 2, 406.60, '2026-07-21 08:00:00', 1),
(25, 21, 3, 112.29, '2026-08-08 17:00:00', 1),
(26, 22, 1, 606.69, '2026-08-28 11:00:00', 1),
(27, 24, 4, 420.03, '2026-08-15 16:00:00', 1),
(28, 25, 4, 302.76, '2026-07-03 17:00:00', 1),
(29, 26, 2, 74.12, '2026-07-02 16:00:00', 1),
(30, 28, 3, 72.89, '2026-07-29 17:00:00', 1);
