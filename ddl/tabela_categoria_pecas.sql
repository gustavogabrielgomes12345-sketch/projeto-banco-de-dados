CREATE TABLE categorias_peca (
    categoria_peca_id  INT PRIMARY KEY,
    descricao          VARCHAR(80) NOT NULL,
    CONSTRAINT uq_categorias_peca_descricao UNIQUE (descricao)
);
