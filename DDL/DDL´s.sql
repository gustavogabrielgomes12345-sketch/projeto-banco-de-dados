-- ============================================================================
-- DEFINIÇÃO DE ESTRUTURA (DDL)
-- ============================================================================

-- ============================================================================
-- CORREÇÃO FEITA PELO QUE FOI SOLICITADO EM AULA:
-- Padrão de Chave Primária: 'id' em todas as tabelas.
-- Ordem de criação estruturada respeitando as dependências de dados.
-- Manter todos os comandos no mesmo arquivo porém separados com comentários explicativos.
-- ============================================================================

-- 1. Tabela de Clientes (Pessoas físicas ou jurídicas)
CREATE TABLE clientes (
    id              INT PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    cpf_cnpj        VARCHAR(20)  NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    data_cadastro   DATE NOT NULL,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE
);

-- 2. Tabela de Veículos (Veículos associados a cada cliente)
CREATE TABLE veiculos (
    id              INT PRIMARY KEY,
    placa           VARCHAR(10) NOT NULL,
    marca           VARCHAR(50) NOT NULL,
    modelo          VARCHAR(50) NOT NULL,
    ano_fabricacao  INT,
    ano_modelo      INT,
    cor             VARCHAR(30),
    quilometragem   INT,
    cliente_id      INT NOT NULL REFERENCES clientes(id)
);

-- 3. Tabela de Tipos de Funcionário (Cargos e Funções)
CREATE TABLE tipos_funcionario (
    id              INT PRIMARY KEY,
    descricao       VARCHAR(50) NOT NULL
);

-- 4. Tabela de Funcionários (Equipe interna da oficina)
CREATE TABLE funcionarios (
    id                  INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    cpf                 VARCHAR(14) NOT NULL,
    telefone            VARCHAR(20),
    data_admissao       DATE NOT NULL,
    salario             DECIMAL(10,2) NOT NULL,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    tipo_funcionario_id INT NOT NULL REFERENCES tipos_funcionario(id)
);

-- 5. Tabela de Fornecedores (Empresas parceiras que fornecem autopeças)
CREATE TABLE fornecedores (
    id              INT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(20) NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200)
);

-- 6. Tabela de Categorias de Peça (Classificação técnica)
CREATE TABLE categorias_peca (
    id              INT PRIMARY KEY,
    descricao       VARCHAR(80) NOT NULL
);

-- 7. Tabela de Peças (Catálogo de autopeças e insumos)
CREATE TABLE pecas (
    id                  INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    preco_custo         DECIMAL(10,2) NOT NULL,
    preco_venda         DECIMAL(10,2) NOT NULL,
    unidade_medida      VARCHAR(10) NOT NULL,
    categoria_peca_id   INT NOT NULL REFERENCES categorias_peca(id),
    fornecedor_id       INT NOT NULL REFERENCES fornecedores(id)
);

-- 8. Tabela de Estoques (Posição atual de saldos e reservas)
CREATE TABLE estoques (
    id                   INT PRIMARY KEY,
    peca_id              INT NOT NULL REFERENCES pecas(id),
    quantidade_atual     INT NOT NULL DEFAULT 0,
    quantidade_reservada INT NOT NULL DEFAULT 0,
    quantidade_minima    INT NOT NULL DEFAULT 0,
    localizacao          VARCHAR(50),
    data_atualizacao     DATE
);

-- 9. Tabela de Movimentações de Estoque (Histórico de entradas e saídas)
CREATE TABLE movimentacoes_estoque (
    id                      INT PRIMARY KEY,
    peca_id                 INT NOT NULL REFERENCES pecas(id),
    tipo_movimentacao       VARCHAR(10) NOT NULL,
    quantidade              INT NOT NULL,
    data_movimentacao       TIMESTAMP NOT NULL,
    observacao              VARCHAR(255),
    fornecedor_id           INT REFERENCES fornecedores(id),
    nota_fiscal             VARCHAR(50),
    preco_unitario          DECIMAL(10,2)
);

-- 10. Tabela de Categorias de Serviço
CREATE TABLE categorias_servico (
    id              INT PRIMARY KEY,
    descricao       VARCHAR(80) NOT NULL
);

-- 11. Tabela de Serviços (Catálogo de mão de obra)
CREATE TABLE servicos (
    id                  INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    valor               DECIMAL(10,2) NOT NULL,
    tempo_estimado_min  INT,
    categoria_servico_id INT REFERENCES categorias_servico(id)
);

-- 12. Tabela de Ordens de Serviço (Cabeçalho da OS)
CREATE TABLE ordens_servico (
    id                  INT PRIMARY KEY,
    cliente_id          INT NOT NULL REFERENCES clientes(id),
    veiculo_id          INT NOT NULL REFERENCES veiculos(id),
    funcionario_id      INT NOT NULL REFERENCES funcionarios(id),
    atendente_id        INT REFERENCES funcionarios(id),
    data_abertura       TIMESTAMP NOT NULL,
    data_previsao       DATE,
    data_conclusao      TIMESTAMP,
    status              VARCHAR(20) NOT NULL,
    valor_pecas         DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_mao_obra      DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_total         DECIMAL(10,2) DEFAULT 0,
    observacoes         VARCHAR(255)
);

-- 13. Tabela Associativa de Peças da OS
CREATE TABLE ordens_servico_pecas (
    id                  INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL REFERENCES ordens_servico(id),
    peca_id             INT NOT NULL REFERENCES pecas(id),
    quantidade          INT NOT NULL,
    preco_unitario      DECIMAL(10,2) NOT NULL
);

-- 14. Tabela Associativa de Serviços da OS
CREATE TABLE ordens_servico_servicos (
    id                  INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL REFERENCES ordens_servico(id),
    servico_id          INT NOT NULL REFERENCES servicos(id),
    funcionario_id      INT NOT NULL REFERENCES funcionarios(id),
    valor_cobrado       DECIMAL(10,2) NOT NULL,
    desconto_concedido  DECIMAL(10,2) DEFAULT 0
);

-- 15. Tabela de Formas de Pagamento
CREATE TABLE formas_pagamento (
    id              INT PRIMARY KEY,
    descricao       VARCHAR(30) NOT NULL
);

-- 16. Tabela de Pagamentos Recebidos
CREATE TABLE pagamentos (
    id                  INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL REFERENCES ordens_servico(id),
    forma_pagamento_id  INT NOT NULL REFERENCES formas_pagamento(id),
    valor               DECIMAL(10,2) NOT NULL,
    valor_juros         DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_desconto      DECIMAL(10,2) NOT NULL DEFAULT 0,
    data_pagamento      TIMESTAMP NOT NULL,
    parcelas            INT NOT NULL DEFAULT 1
);

-- 17. Tabela de Auditoria de Reajuste de Preço de Peças
CREATE TABLE log_preco_pecas (
    id              SERIAL PRIMARY KEY,
    peca_id         INT NOT NULL REFERENCES pecas(id),
    preco_antigo    DECIMAL(10,2) NOT NULL,
    preco_novo      DECIMAL(10,2) NOT NULL,
    data_alteracao  TIMESTAMP NOT NULL,
    usuario         VARCHAR(100) NOT NULL
);

-- 18. Tabela de Cobranças (Controle de parcelas / contas a receber)
CREATE TABLE cobrancas (
    id                  INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL REFERENCES ordens_servico(id),
    data_emissao        DATE NOT NULL DEFAULT CURRENT_DATE,
    data_vencimento     DATE NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    status              VARCHAR(20) NOT NULL
);
