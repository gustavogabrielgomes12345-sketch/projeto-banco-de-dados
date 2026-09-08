CREATE TABLE servicos (
    servico_id          INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    valor               DECIMAL(10,2) NOT NULL,
    tempo_estimado_min  INT
);