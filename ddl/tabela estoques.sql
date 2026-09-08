CREATE TABLE estoques (
    estoque_id          INT PRIMARY KEY,
    peca_id             INT NOT NULL,
    quantidade_atual    INT NOT NULL DEFAULT 0,
    quantidade_minima   INT NOT NULL DEFAULT 0,
    localizacao         VARCHAR(50),
    data_atualizacao    DATE
);