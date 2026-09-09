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
