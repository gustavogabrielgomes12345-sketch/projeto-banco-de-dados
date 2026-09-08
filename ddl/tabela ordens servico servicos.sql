CREATE TABLE ordens_servico_servicos (
    ordem_servico_servico_id   INT PRIMARY KEY,
    ordem_servico_id           INT NOT NULL,
    servico_id                 INT NOT NULL,
    funcionario_id             INT NOT NULL, 
    valor_cobrado               DECIMAL(10,2) NOT NULL
);