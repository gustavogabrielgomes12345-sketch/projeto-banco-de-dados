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
