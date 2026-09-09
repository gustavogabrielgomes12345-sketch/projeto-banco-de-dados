CREATE TABLE movimentacoes_estoque (
    movimentacao_estoque_id INT PRIMARY KEY,
    peca_id                 INT NOT NULL,
    tipo_movimentacao       VARCHAR(10) NOT NULL,
    quantidade              INT NOT NULL,
    data_movimentacao       TIMESTAMP NOT NULL,
    observacao              VARCHAR(255),
    CONSTRAINT ck_movimentacoes_tipo
        CHECK (tipo_movimentacao IN ('ENTRADA','SAIDA')),
    CONSTRAINT fk_movimentacoes_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE CASCADE
);
