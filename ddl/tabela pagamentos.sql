CREATE TABLE pagamentos (
    pagamento_id        INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL,
    forma_pagamento_id  INT NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    data_pagamento      TIMESTAMP NOT NULL,
    parcelas            INT NOT NULL DEFAULT 1
);