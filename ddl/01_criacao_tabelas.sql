-- =====================================================================
-- DDL - Oficina Mecânica
-- Etapa 4 da atividade: estrutura básica das tabelas, AINDA SEM FOREIGN KEY.
-- Padrão de nomenclatura: snake_case, tabelas no plural, PK sempre por
-- extenso (ex.: cliente_id), colunas que futuramente serão FK já nascem
-- com o MESMO nome da coluna que vão referenciar.
-- Referência: https://dev.to/ovid/database-naming-standards-2061
-- Testado com sintaxe compatível com PostgreSQL.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Cadastro de clientes
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    cliente_id      INT PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    cpf_cnpj        VARCHAR(20)  NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    data_cadastro   DATE NOT NULL,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------
-- Veículos pertencentes a um cliente
-- (cliente_id ainda sem FK -> será ligado a clientes.cliente_id depois)
-- ---------------------------------------------------------------------
CREATE TABLE veiculos (
    veiculo_id      INT PRIMARY KEY,
    placa           VARCHAR(10) NOT NULL,
    marca           VARCHAR(50) NOT NULL,
    modelo          VARCHAR(50) NOT NULL,
    ano_fabricacao  INT,
    ano_modelo      INT,
    cor             VARCHAR(30),
    quilometragem   INT,
    cliente_id      INT NOT NULL
);

-- ---------------------------------------------------------------------
-- Cargos/funções da equipe (Mecânico, Atendente, Gerente, Caixa...)
-- ---------------------------------------------------------------------
CREATE TABLE tipos_funcionario (
    tipo_funcionario_id INT PRIMARY KEY,
    descricao            VARCHAR(50) NOT NULL
);

-- ---------------------------------------------------------------------
-- Funcionários da oficina
-- ---------------------------------------------------------------------
CREATE TABLE funcionarios (
    funcionario_id      INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    cpf                 VARCHAR(14) NOT NULL,
    telefone            VARCHAR(20),
    data_admissao       DATE NOT NULL,
    salario             DECIMAL(10,2) NOT NULL,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    tipo_funcionario_id INT NOT NULL
);

-- ---------------------------------------------------------------------
-- Fornecedores de peças
-- ---------------------------------------------------------------------
CREATE TABLE fornecedores (
    fornecedor_id   INT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(20) NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200)
);

-- ---------------------------------------------------------------------
-- Categorias de peça (motor, freio, elétrica, suspensão...)
-- ---------------------------------------------------------------------
CREATE TABLE categorias_peca (
    categoria_peca_id  INT PRIMARY KEY,
    descricao          VARCHAR(80) NOT NULL
);

-- ---------------------------------------------------------------------
-- Catálogo de peças
-- ---------------------------------------------------------------------
CREATE TABLE pecas (
    peca_id             INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    preco_custo         DECIMAL(10,2) NOT NULL,
    preco_venda         DECIMAL(10,2) NOT NULL,
    unidade_medida      VARCHAR(10) NOT NULL,
    categoria_peca_id   INT NOT NULL,
    fornecedor_id       INT NOT NULL
);

-- ---------------------------------------------------------------------
-- Saldo de estoque de cada peça
-- ---------------------------------------------------------------------
CREATE TABLE estoques (
    estoque_id          INT PRIMARY KEY,
    peca_id             INT NOT NULL,
    quantidade_atual    INT NOT NULL DEFAULT 0,
    quantidade_minima   INT NOT NULL DEFAULT 0,
    localizacao         VARCHAR(50),
    data_atualizacao    DATE
);

-- ---------------------------------------------------------------------
-- Histórico de entradas e saídas de peças no estoque
-- ---------------------------------------------------------------------
CREATE TABLE movimentacoes_estoque (
    movimentacao_estoque_id INT PRIMARY KEY,
    peca_id                 INT NOT NULL,
    tipo_movimentacao       VARCHAR(10) NOT NULL, -- 'ENTRADA' ou 'SAIDA'
    quantidade              INT NOT NULL,
    data_movimentacao       TIMESTAMP NOT NULL,
    observacao              VARCHAR(255)
);

-- ---------------------------------------------------------------------
-- Catálogo de serviços prestados pela oficina
-- ---------------------------------------------------------------------
CREATE TABLE servicos (
    servico_id          INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    valor               DECIMAL(10,2) NOT NULL,
    tempo_estimado_min  INT
);

-- ---------------------------------------------------------------------
-- Ordem de serviço aberta para um veículo/cliente
-- ---------------------------------------------------------------------
CREATE TABLE ordens_servico (
    ordem_servico_id    INT PRIMARY KEY,
    cliente_id          INT NOT NULL,
    veiculo_id          INT NOT NULL,
    funcionario_id      INT NOT NULL, -- responsável pela abertura/atendimento
    data_abertura       TIMESTAMP NOT NULL,
    data_previsao       DATE,
    data_conclusao      TIMESTAMP,
    status              VARCHAR(20) NOT NULL, -- ABERTA, EM_ANDAMENTO, CONCLUIDA, CANCELADA
    valor_total         DECIMAL(10,2) NOT NULL DEFAULT 0,
    observacoes         VARCHAR(255)
);

-- ---------------------------------------------------------------------
-- Peças utilizadas em uma ordem de serviço (tabela associativa N:N)
-- ---------------------------------------------------------------------
CREATE TABLE ordens_servico_pecas (
    ordem_servico_peca_id  INT PRIMARY KEY,
    ordem_servico_id       INT NOT NULL,
    peca_id                INT NOT NULL,
    quantidade             INT NOT NULL,
    preco_unitario         DECIMAL(10,2) NOT NULL
);

-- ---------------------------------------------------------------------
-- Serviços realizados em uma ordem de serviço (tabela associativa N:N)
-- ---------------------------------------------------------------------
CREATE TABLE ordens_servico_servicos (
    ordem_servico_servico_id   INT PRIMARY KEY,
    ordem_servico_id           INT NOT NULL,
    servico_id                 INT NOT NULL,
    funcionario_id             INT NOT NULL, -- quem executou o serviço
    valor_cobrado               DECIMAL(10,2) NOT NULL
);

-- ---------------------------------------------------------------------
-- Formas de pagamento aceitas
-- ---------------------------------------------------------------------
CREATE TABLE formas_pagamento (
    forma_pagamento_id  INT PRIMARY KEY,
    descricao           VARCHAR(30) NOT NULL -- Dinheiro, Pix, Cartão Débito, Cartão Crédito, Boleto
);

-- ---------------------------------------------------------------------
-- Pagamentos recebidos referentes a uma ordem de serviço
-- ---------------------------------------------------------------------
CREATE TABLE pagamentos (
    pagamento_id        INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL,
    forma_pagamento_id  INT NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    data_pagamento      TIMESTAMP NOT NULL,
    parcelas            INT NOT NULL DEFAULT 1
);
