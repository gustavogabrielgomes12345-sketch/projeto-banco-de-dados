CREATE TABLE pecas (
    peca_id             INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    preco_custo         DECIMAL(10,2) NOT NULL,
    preco_venda         DECIMAL(10,2) NOT NULL,
    unidade_medida      VARCHAR(10) NOT NULL,
    categoria_peca_id   INT NOT NULL,
    fornecedor_id       INT NOT NULL
);