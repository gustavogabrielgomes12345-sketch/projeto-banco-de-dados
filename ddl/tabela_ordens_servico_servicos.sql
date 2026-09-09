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
