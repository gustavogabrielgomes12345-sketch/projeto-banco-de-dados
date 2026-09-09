CREATE TABLE veiculos (
    veiculo_id      INT PRIMARY KEY,
    placa           VARCHAR(10) NOT NULL,
    marca           VARCHAR(50) NOT NULL,
    modelo          VARCHAR(50) NOT NULL,
    ano_fabricacao  INT,
    ano_modelo      INT,
    cor             VARCHAR(30),
    quilometragem   INT,
    cliente_id      INT NOT NULL,
    CONSTRAINT uq_veiculos_placa UNIQUE (placa),
    CONSTRAINT fk_veiculos_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id)
        ON DELETE RESTRICT
);
