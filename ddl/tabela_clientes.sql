CREATE TABLE clientes (
    cliente_id      INT PRIMARY KEY,
    nome            VARCHAR(150) NOT NULL,
    cpf_cnpj        VARCHAR(20)  NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    data_cadastro   DATE NOT NULL,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_clientes_cpf_cnpj UNIQUE (cpf_cnpj)
);
