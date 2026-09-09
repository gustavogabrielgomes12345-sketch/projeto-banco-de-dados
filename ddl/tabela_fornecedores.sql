CREATE TABLE fornecedores (
    fornecedor_id   INT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(20) NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    CONSTRAINT uq_fornecedores_cnpj UNIQUE (cnpj)
);
