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