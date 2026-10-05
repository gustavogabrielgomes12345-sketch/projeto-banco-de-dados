-- ============================================================================
-- DEFINIÇÃO DE ESTRUTURA (DDL - DATA DEFINITION LANGUAGE)
-- Padrão de Chave Primária: 'id' em todas as tabelas.
-- Ordem de criação estruturada respeitando as dependências de dados.
-- ============================================================================

-- 1. Tabela de Clientes (Pessoas físicas ou jurídicas)
CREATE TABLE clientes (
    id              INT PRIMARY KEY,              -- Chave primária do cliente
    nome            VARCHAR(150) NOT NULL,        -- Nome completo ou razão social
    cpf_cnpj        VARCHAR(20)  NOT NULL,        -- CPF ou CNPJ
    telefone        VARCHAR(20),                  -- Telefone de contato principal
    email           VARCHAR(150),                 -- Endereço de e-mail de contato
    endereco        VARCHAR(200),                 -- Endereço residencial/comercial
    data_cadastro   DATE NOT NULL,                -- Data em que o cliente foi cadastrado
    ativo           BOOLEAN NOT NULL DEFAULT TRUE -- Indica se o cadastro está ativo no sistema
);

-- 2. Tabela de Veículos (Veículos associados a cada cliente)
CREATE TABLE veiculos (
    id              INT PRIMARY KEY,              -- Chave primária do veículo
    placa           VARCHAR(10) NOT NULL,         -- Placa do veículo (Formato antigo ou Mercosul)
    marca           VARCHAR(50) NOT NULL,         -- Marca do veículo (ex: Fiat, Ford)
    modelo          VARCHAR(50) NOT NULL,         -- Modelo do veículo (ex: Uno, Ranger)
    ano_fabricacao  INT,                          -- Ano de fabricação do veículo
    ano_modelo      INT,                          -- Ano do modelo do veículo
    cor             VARCHAR(30),                  -- Cor predominante
    quilometragem   INT,                          -- Quilometragem atual registrada
    cliente_id      INT NOT NULL                  -- Chave estrangeira ligando ao id do cliente
);

-- 3. Tabela de Tipos de Funcionário (Cargos e Funções)
CREATE TABLE tipos_funcionario (
    id              INT PRIMARY KEY,              -- Chave primária do cargo/função
    descricao       VARCHAR(50) NOT NULL          -- Descrição da função (Mecânico, Atendente, etc)
);

-- 4. Tabela de Funcionários (Equipe interna da oficina)
CREATE TABLE funcionarios (
    id                  INT PRIMARY KEY,              -- Chave primária do funcionário
    nome                VARCHAR(150) NOT NULL,        -- Nome completo do funcionário
    cpf                 VARCHAR(14) NOT NULL,         -- Número do CPF
    telefone            VARCHAR(20),                  -- Telefone de contato
    data_admissao       DATE NOT NULL,                -- Data de contratação do funcionário
    salario             DECIMAL(10,2) NOT NULL,       -- Valor do salário base
    ativo               BOOLEAN NOT NULL DEFAULT TRUE, -- Situação do contrato (ativo/inativo)
    tipo_funcionario_id INT NOT NULL                  -- Chave estrangeira ligando ao id do cargo
);

-- 5. Tabela de Fornecedores (Empresas parceiras que fornecem autopeças)
CREATE TABLE fornecedores (
    id              INT PRIMARY KEY,              -- Chave primária do fornecedor
    razao_social    VARCHAR(150) NOT NULL,        -- Nome comercial da empresa
    cnpj            VARCHAR(20) NOT NULL,         -- Cadastro Nacional da Pessoa Jurídica
    telefone        VARCHAR(20),                  -- Telefone comercial
    email           VARCHAR(150),                 -- E-mail para cotações e pedidos
    endereco        VARCHAR(200)                  -- Endereço da sede/distribuidora
);

-- 6. Tabela de Categorias de Peça (Classificação técnica)
CREATE TABLE categorias_peca (
    id              INT PRIMARY KEY,              -- Chave primária da categoria
    descricao       VARCHAR(80) NOT NULL          -- Descrição (Motor, Freios, Elétrica, etc)
);

-- 7. Tabela de Peças (Catálogo de autopeças e insumos)
CREATE TABLE pecas (
    id                  INT PRIMARY KEY,          -- Chave primária da peça
    nome                VARCHAR(150) NOT NULL,    -- Nome comercial do produto/peça
    descricao           VARCHAR(255),             -- Especificações técnicas
    preco_custo         DECIMAL(10,2) NOT NULL,   -- Valor pago na aquisição junto ao fornecedor
    preco_venda         DECIMAL(10,2) NOT NULL,   -- Valor praticado para venda/aplicação
    unidade_medida      VARCHAR(10) NOT NULL,     -- Unidade de medida (UN, JG, L, etc)
    categoria_peca_id   INT NOT NULL,             -- Chave estrangeira ligando ao id da categoria
    fornecedor_id       INT NOT NULL              -- Chave estrangeira ligando ao id do fornecedor
);

-- 8. Tabela de Estoques (Posição atual de saldos)
CREATE TABLE estoques (
    id                  INT PRIMARY KEY,          -- Chave primária do registro de estoque
    peca_id             INT NOT NULL,             -- Chave estrangeira ligando ao id da peça
    quantidade_atual    INT NOT NULL DEFAULT 0,   -- Saldo físico disponível
    quantidade_minima   INT NOT NULL DEFAULT 0,   -- Ponto de reposição mínimo recomendado
    localizacao         VARCHAR(50),              -- Corredor/Prateleira no almoxarifado
    data_atualizacao    DATE                      -- Data do último balanço ou movimentação
);

-- 9. Tabela de Movimentações de Estoque (Histórico de entradas e saídas)
CREATE TABLE movimentacoes_estoque (
    id                      INT PRIMARY KEY,      -- Chave primária do registro
    peca_id                 INT NOT NULL,         -- Chave estrangeira ligando ao id da peça
    tipo_movimentacao       VARCHAR(10) NOT NULL, -- Indicador de direção: 'ENTRADA' ou 'SAIDA'
    quantidade              INT NOT NULL,         -- Quantidade movimentada
    data_movimentacao       TIMESTAMP NOT NULL,   -- Data e hora exata da operação
    observacao              VARCHAR(255)          -- Motivo ou referência da movimentação
);

-- 10. Tabela de Serviços (Catálogo de mão de obra)
CREATE TABLE servicos (
    id                  INT PRIMARY KEY,          -- Chave primária do serviço
    nome                VARCHAR(150) NOT NULL,    -- Descrição do procedimento (Troca de Óleo, etc)
    descricao           VARCHAR(255),             -- Detalhes da rotina técnica
    valor               DECIMAL(10,2) NOT NULL,   -- Preço padrão da mão de obra
    tempo_estimado_min  INT                       -- Duração média estimada em minutos
);

-- 11. Tabela de Ordens de Serviço (Cabeçalho da OS)
CREATE TABLE ordens_servico (
    id                  INT PRIMARY KEY,          -- Chave primária da Ordem de Serviço
    cliente_id          INT NOT NULL,             -- Chave estrangeira ligando ao id do cliente
    veiculo_id          INT NOT NULL,             -- Chave estrangeira ligando ao id do veículo
    funcionario_id      INT NOT NULL,             -- Chave estrangeira ligando ao id do mecânico responsável
    data_abertura       TIMESTAMP NOT NULL,       -- Data e hora do início do atendimento
    data_previsao       DATE,                     -- Data estimada de entrega do veículo
    data_conclusao      TIMESTAMP,                -- Data e hora de finalização dos trabalhos
    status              VARCHAR(20) NOT NULL,     -- Situação ('ABERTA', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA')
    valor_total         DECIMAL(10,2) DEFAULT 0,  -- Somatório consolidado da OS
    observacoes         VARCHAR(255)              -- Anotações do atendimento
);

-- 12. Tabela Associativa de Peças da OS
CREATE TABLE ordens_servico_pecas (
    id                  INT PRIMARY KEY,          -- Chave primária do item de peça da OS
    ordem_servico_id    INT NOT NULL,             -- Chave estrangeira ligando ao id da OS
    peca_id             INT NOT NULL,             -- Chave estrangeira ligando ao id da peça utilizada
    quantidade          INT NOT NULL,             -- Quantidade aplicada no serviço
    preco_unitario      DECIMAL(10,2) NOT NULL    -- Valor unitário cobrado na OS
);

-- 13. Tabela Associativa de Serviços da OS
CREATE TABLE ordens_servico_servicos (
    id                  INT PRIMARY KEY,          -- Chave primária do item de serviço da OS
    ordem_servico_id    INT NOT NULL,             -- Chave estrangeira ligando ao id da OS
    servico_id          INT NOT NULL,             -- Chave estrangeira ligando ao id do serviço executado
    funcionario_id      INT NOT NULL,             -- Chave estrangeira ligando ao id do mecânico executor
    valor_cobrado       DECIMAL(10,2) NOT NULL,   -- Preço cobrado pela mão de obra
    desconto_concedido  DECIMAL(10,2) DEFAULT 0   -- Valor de abatimento ou desconto concedido
);

-- 14. Tabela de Formas de Pagamento
CREATE TABLE formas_pagamento (
    id              INT PRIMARY KEY,              -- Chave primária da modalidade de pagamento
    descricao       VARCHAR(30) NOT NULL          -- Descrição (Dinheiro, Pix, Cartão de Crédito, etc)
);

-- 15. Tabela de Pagamentos Recebidos
CREATE TABLE pagamentos (
    id                  INT PRIMARY KEY,          -- Chave primária do recebimento
    ordem_servico_id    INT NOT NULL,             -- Chave estrangeira ligando ao id da OS
    forma_pagamento_id  INT NOT NULL,             -- Chave estrangeira ligando ao id da forma de pagamento
    valor               DECIMAL(10,2) NOT NULL,   -- Quantia total paga
    data_pagamento      TIMESTAMP NOT NULL,       -- Data e hora da transação
    parcelas            INT NOT NULL DEFAULT 1    -- Quantidade de parcelas acertadas
);