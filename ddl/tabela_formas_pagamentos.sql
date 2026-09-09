CREATE TABLE formas_pagamento (
    forma_pagamento_id  INT PRIMARY KEY,
    descricao           VARCHAR(30) NOT NULL,
    CONSTRAINT uq_formas_pagamento_descricao UNIQUE (descricao)
);
