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
    cliente_id      INT NOT NULL                  
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
    tipo_funcionario_id INT NOT NULL                  
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
    categoria_peca_id   INT NOT NULL,             
    fornecedor_id       INT NOT NULL              
);

-- 8. Tabela de Estoques (Posição atual de saldos)
CREATE TABLE estoques (
    id                  INT PRIMARY KEY,          
    peca_id             INT NOT NULL,             
    quantidade_atual    INT NOT NULL DEFAULT 0,   
    quantidade_minima   INT NOT NULL DEFAULT 0,   
    localizacao         VARCHAR(50),              
    data_atualizacao    DATE                      
);

-- 9. Tabela de Movimentações de Estoque (Histórico de entradas e saídas)
CREATE TABLE movimentacoes_estoque (
    id                      INT PRIMARY KEY,      
    peca_id                 INT NOT NULL,         
    tipo_movimentacao       VARCHAR(10) NOT NULL, 
    quantidade              INT NOT NULL,         
    data_movimentacao       TIMESTAMP NOT NULL,   
    observacao              VARCHAR(255)          
);

-- 10. Tabela de Serviços (Catálogo de mão de obra)
CREATE TABLE servicos (
    id                  INT PRIMARY KEY,          
    nome                VARCHAR(150) NOT NULL,    
    descricao           VARCHAR(255),             
    valor               DECIMAL(10,2) NOT NULL,   
    tempo_estimado_min  INT                       
);

-- 11. Tabela de Ordens de Serviço (Cabeçalho da OS)
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

-- 12. Tabela Associativa de Peças da OS
CREATE TABLE ordens_servico_pecas (
    id                  INT PRIMARY KEY,          
    ordem_servico_id    INT NOT NULL,             
    peca_id             INT NOT NULL,             
    quantidade          INT NOT NULL,             
    preco_unitario      DECIMAL(10,2) NOT NULL    
);

-- 13. Tabela Associativa de Serviços da OS
CREATE TABLE ordens_servico_servicos (
    id                  INT PRIMARY KEY,          
    ordem_servico_id    INT NOT NULL,             
    servico_id          INT NOT NULL,             
    funcionario_id      INT NOT NULL,             
    valor_cobrado       DECIMAL(10,2) NOT NULL,   
    desconto_concedido  DECIMAL(10,2) DEFAULT 0   
);

-- 14. Tabela de Formas de Pagamento
CREATE TABLE formas_pagamento (
    id              INT PRIMARY KEY,              
    descricao       VARCHAR(30) NOT NULL          
);

-- 15. Tabela de Pagamentos Recebidos
CREATE TABLE pagamentos (
    id                  INT PRIMARY KEY,          
    ordem_servico_id    INT NOT NULL,             
    forma_pagamento_id  INT NOT NULL,             
    valor               DECIMAL(10,2) NOT NULL,   
    data_pagamento      TIMESTAMP NOT NULL,       
    parcelas            INT NOT NULL DEFAULT 1    
);