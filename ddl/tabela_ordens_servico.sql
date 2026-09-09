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
