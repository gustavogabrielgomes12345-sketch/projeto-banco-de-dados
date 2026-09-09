CREATE TABLE pagamentos (
    pagamento_id        INT PRIMARY KEY,
    ordem_servico_id    INT NOT NULL,
    forma_pagamento_id  INT NOT NULL,
    valor               DECIMAL(10,2) NOT NULL,
    data_pagamento      TIMESTAMP NOT NULL,
    parcelas            INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_pagamentos_ordem_servico
        FOREIGN KEY (ordem_servico_id)
        REFERENCES ordens_servico (ordem_servico_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pagamentos_forma
        FOREIGN KEY (forma_pagamento_id)
        REFERENCES formas_pagamento (forma_pagamento_id)
        ON DELETE RESTRICT
);
