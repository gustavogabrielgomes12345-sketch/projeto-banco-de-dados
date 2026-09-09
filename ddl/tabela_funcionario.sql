CREATE TABLE funcionarios (
    funcionario_id      INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    cpf                 VARCHAR(14) NOT NULL,
    telefone            VARCHAR(20),
    data_admissao       DATE NOT NULL,
    salario             DECIMAL(10,2) NOT NULL,
    ativo               BOOLEAN NOT NULL DEFAULT TRUE,
    tipo_funcionario_id INT NOT NULL,
    CONSTRAINT uq_funcionarios_cpf UNIQUE (cpf),
    CONSTRAINT fk_funcionarios_tipo
        FOREIGN KEY (tipo_funcionario_id)
        REFERENCES tipos_funcionario (tipo_funcionario_id)
        ON DELETE RESTRICT
);
