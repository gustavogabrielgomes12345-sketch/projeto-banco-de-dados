
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


CREATE TABLE tipos_funcionario (
    tipo_funcionario_id INT PRIMARY KEY,
    descricao            VARCHAR(50) NOT NULL
);


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


CREATE TABLE fornecedores (
    fornecedor_id   INT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(20) NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200)
);


CREATE TABLE categorias_peca (
    categoria_peca_id  INT PRIMARY KEY,
    descricao          VARCHAR(80) NOT NULL
);


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


CREATE TABLE estoques (
    estoque_id          INT PRIMARY KEY,
    peca_id             INT NOT NULL,
    quantidade_atual    INT NOT NULL DEFAULT 0,
    quantidade_minima   INT NOT NULL DEFAULT 0,
    localizacao         VARCHAR(50),
    data_atualizacao    DATE
);


CREATE TABLE movimentacoes_estoque (
    movimentacao_estoque_id INT PRIMARY KEY,
    peca_id                 INT NOT NULL,
    tipo_movimentacao       VARCHAR(10) NOT NULL, 
    quantidade              INT NOT NULL,
    data_movimentacao       TIMESTAMP NOT NULL,
    observacao              VARCHAR(255)
);

CREATE TABLE servicos (
    servico_id          INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    valor               DECIMAL(10,2) NOT NULL,
    tempo_estimado_min  INT
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
    observacoes         VARCHAR(255)
);


    ordem_servico_peca_id  INT PRIMARY KEY,
    ordem_servico_id       INT NOT NULL,
    peca_id                INT NOT NULL,
    quantidade             INT NOT NULL,
    preco_unitario         DECIMAL(10,2) NOT NULL
);


CREATE TABLE ordens_servico_servicos (
    ordem_servico_servico_id   INT PRIMARY KEY,
    ordem_servico_id           INT NOT NULL,
    servico_id                 INT NOT NULL,
    funcionario_id             INT NOT NULL, 
    valor_cobrado               DECIMAL(10,2) NOT NULL
);


CREATE TABLE formas_pagamento (
    forma_pagamento_id  INT PRIMARY KEY,
    descricao           VARCHAR(30) NOT NULL 
);

CREATE TABLE pagamentos (
    pagamento_id        INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL,
    forma_pagamento_id  INT NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    data_pagamento      TIMESTAMP NOT NULL,
    parcelas            INT NOT NULL DEFAULT 1
);
