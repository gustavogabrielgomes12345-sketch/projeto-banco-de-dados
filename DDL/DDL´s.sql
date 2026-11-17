-- ============================================================================
-- 1. DEFINIÇÃO DE ESTRUTURA (DDL) E ALTERAÇÕES - OFICINA MECÂNICA
-- ============================================================================

-- Tabelas Principais (Estrutura Base)
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

CREATE TABLE veiculos (
    id              INT PRIMARY KEY,              
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
    id              INT PRIMARY KEY,              
    descricao       VARCHAR(50) NOT NULL          
);

CREATE TABLE funcionarios (
    id                  INT PRIMARY KEY,              
    nome                VARCHAR(150) NOT NULL,        
    cpf                 VARCHAR(14) NOT NULL,         
    telefone            VARCHAR(20),                  
    data_admissao       DATE NOT NULL,                
    salario             DECIMAL(10,2) NOT NULL,       
    ativo               BOOLEAN NOT NULL DEFAULT TRUE, 
    tipo_funcionario_id INT NOT NULL                  
);

CREATE TABLE fornecedores (
    id              INT PRIMARY KEY,              
    razao_social    VARCHAR(150) NOT NULL,        
    cnpj            VARCHAR(20) NOT NULL,         
    telefone        VARCHAR(20),                  
    email           VARCHAR(150),                 
    endereco        VARCHAR(200)                  
);

CREATE TABLE categorias_peca (
    id              INT PRIMARY KEY,              
    descricao       VARCHAR(80) NOT NULL          
);

CREATE TABLE pecas (
    id                  INT PRIMARY KEY,          
    nome                VARCHAR(150) NOT NULL,    
    descricao           VARCHAR(255),             
    preco_custo         DECIMAL(10,2) NOT NULL,   
    preco_venda         DECIMAL(10,2) NOT NULL,   
    unidade_medida      VARCHAR(10) NOT NULL,     
    categoria_peca_id   INT NOT NULL,             
    fornecedor_id       INT NOT NULL              
);

CREATE TABLE estoques (
    id                  INT PRIMARY KEY,          
    peca_id             INT NOT NULL,             
    quantidade_atual    INT NOT NULL DEFAULT 0,   
    quantidade_minima   INT NOT NULL DEFAULT 0,   
    localizacao         VARCHAR(50),              
    data_atualizacao    DATE                      
);

CREATE TABLE movimentacoes_estoque (
    id                      INT PRIMARY KEY,      
    peca_id                 INT NOT NULL,         
    tipo_movimentacao       VARCHAR(10) NOT NULL, 
    quantidade              INT NOT NULL,         
    data_movimentacao       TIMESTAMP NOT NULL,   
    observacao              VARCHAR(255)          
);

CREATE TABLE servicos (
    id                  INT PRIMARY KEY,          
    nome                VARCHAR(150) NOT NULL,    
    descricao           VARCHAR(255),             
    valor               DECIMAL(10,2) NOT NULL,   
    tempo_estimado_min  INT                       
);

CREATE TABLE ordens_servico (
    id                  INT PRIMARY KEY,          
    cliente_id          INT NOT NULL,             
    veiculo_id          INT NOT NULL,             
    funcionario_id      INT NOT NULL,             
    data_abertura       TIMESTAMP NOT NULL,       
    data_previsao       DATE,                     
    data_conclusao      TIMESTAMP,                
    status              VARCHAR(20) NOT NULL,     
    valor_total         DECIMAL(10,2) DEFAULT 0,  
    observacoes         VARCHAR(255)              
);

CREATE TABLE ordens_servico_pecas (
    id                  INT PRIMARY KEY,          
    ordem_servico_id    INT NOT NULL,             
    peca_id             INT NOT NULL,             
    quantidade          INT NOT NULL,             
    preco_unitario      DECIMAL(10,2) NOT NULL    
);

CREATE TABLE ordens_servico_servicos (
    id                  INT PRIMARY KEY,          
    ordem_servico_id    INT NOT NULL,             
    servico_id          INT NOT NULL,             
    funcionario_id      INT NOT NULL,             
    valor_cobrado       DECIMAL(10,2) NOT NULL,   
    desconto_concedido  DECIMAL(10,2) DEFAULT 0   
);

CREATE TABLE formas_pagamento (
    id              INT PRIMARY KEY,              
    descricao       VARCHAR(30) NOT NULL          
);

CREATE TABLE pagamentos (
    id                  INT PRIMARY KEY,          
    ordem_servico_id    INT NOT NULL,             
    forma_pagamento_id  INT NOT NULL,             
    valor               DECIMAL(10,2) NOT NULL,   
    data_pagamento      TIMESTAMP NOT NULL,       
    parcelas            INT NOT NULL DEFAULT 1    
);

-- ============================================================================
-- ALTERAÇÕES E NOVAS TABELAS (Demandadas por PSM e Triggers)
-- ============================================================================
ALTER TABLE ordens_servico ADD COLUMN IF NOT EXISTS atendente_id INT;
ALTER TABLE ordens_servico ADD COLUMN IF NOT EXISTS valor_pecas DECIMAL(10,2) NOT NULL DEFAULT 0;
ALTER TABLE ordens_servico ADD COLUMN IF NOT EXISTS valor_mao_obra DECIMAL(10,2) NOT NULL DEFAULT 0;

ALTER TABLE estoques ADD COLUMN IF NOT EXISTS quantidade_reservada INT NOT NULL DEFAULT 0;

ALTER TABLE movimentacoes_estoque ADD COLUMN IF NOT EXISTS fornecedor_id INT;
ALTER TABLE movimentacoes_estoque ADD COLUMN IF NOT EXISTS nota_fiscal VARCHAR(30);
ALTER TABLE movimentacoes_estoque ADD COLUMN IF NOT EXISTS preco_unitario DECIMAL(10,2);

ALTER TABLE pagamentos ADD COLUMN IF NOT EXISTS valor_juros DECIMAL(10,2) NOT NULL DEFAULT 0;
ALTER TABLE pagamentos ADD COLUMN IF NOT EXISTS valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS cobrancas (
    id                  INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    data_emissao        DATE NOT NULL,
    data_vencimento     DATE NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'PENDENTE'
);

CREATE TABLE IF NOT EXISTS categorias_servico (
    id                  INT PRIMARY KEY,
    descricao           VARCHAR(80) NOT NULL
);
ALTER TABLE servicos ADD COLUMN IF NOT EXISTS categoria_servico_id INT;

CREATE TABLE IF NOT EXISTS log_preco_pecas (
    id                  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    peca_id             INT NOT NULL,
    preco_antigo        DECIMAL(10,2) NOT NULL,
    preco_novo          DECIMAL(10,2) NOT NULL,
    data_alteracao      TIMESTAMP NOT NULL DEFAULT CURRENT_USER,
    usuario             VARCHAR(100) NOT NULL DEFAULT CURRENT_USER
);
