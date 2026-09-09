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
