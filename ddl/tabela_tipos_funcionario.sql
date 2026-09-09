CREATE TABLE tipos_funcionario (
    tipo_funcionario_id INT PRIMARY KEY,
    descricao            VARCHAR(50) NOT NULL,
    CONSTRAINT uq_tipos_funcionario_descricao UNIQUE (descricao)
);
