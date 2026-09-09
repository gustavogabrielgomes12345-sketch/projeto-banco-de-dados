# Modelagem de Banco de Dados — Oficina Mecânica

## 1. Domínio do sistema

O sistema escolhido foi o de uma **oficina mecânica**. O objetivo principal é gerenciar e controlar os processos operacionais e financeiros da oficina, incluindo o cadastro de clientes, veículos atendidos, quadro de colaboradores, catálogo de serviços e peças, fornecedores parceiros, controle de estoque com movimentações, ordens de serviço (OS) e registros de pagamentos efetuados.

## 2. Justificativa do domínio escolhido

Escolhemos uma oficina mecânica porque é um tipo de sistema que possui grande riqueza relacional, dados interdependentes e regras de negócio claras e aplicáveis ao mundo real. Com esse tema, conseguimos trabalhar diferentes conceitos fundamentais de modelagem e banco de dados:

* Relacionamento entre cliente, veículo e ordem de serviço, permitindo trabalhar cardinalidades como 1:N (um cliente possui vários veículos; um veículo pode ter várias OS ao longo do tempo).


* Relações associativas N:N resolvidas em tabelas intermediárias (`ordens_servico_pecas` e `ordens_servico_servicos`), registrando especificamente quais peças e serviços compõem cada OS, com preços praticados e profissionais responsáveis.


* Controle de estoque minucioso para peças, abrangendo saldo atual, estoque mínimo, localização física nas prateleiras e histórico auditável de movimentações (entradas por compra e saídas por OS).


* Registro do ciclo de vida das ordens de serviço (aberta, em andamento, concluída ou cancelada), além do controle de faturamento associado por meio de pagamentos e formas de pagamento.


* Trata-se de um tema amplamente conhecido, facilitando o levantamento de requisitos, discussões de regras de negócio e validação dos dados fictícios populados.



## 3. Padrão de nomenclatura adotado

Baseado nas boas práticas de engenharia de software e banco de dados (referência: *Database Naming Standards — dev.to/ovid*), adotamos os seguintes padrões:

| Decisão | Padrão escolhido | Justificativa técnica |
| --- | --- | --- |
| Case | `snake_case` (letras minúsculas e underscore) | Evita ambiguidades (`under_value` × `undervalue`), garante portabilidade entre diferentes SGBDs e melhora a legibilidade.

 |
| Nome de tabela | **Plural** (`clientes`, `veiculos`, `pecas`, etc.) | Evita colisão direta com palavras reservadas da linguagem SQL (`user`, `order`, `group`), representando formalmente um conjunto/coleção de registros.

 |
| Chave primária | **Nunca `id` isolado** — sempre com prefixo da entidade: `cliente_id`, `veiculo_id`, `peca_id` | Elimina ambiguidades em cláusulas `JOIN` e comandos analíticos complexos (`WHERE clientes.cliente_id = veiculos.cliente_id`), facilitando a leitura e a manutenção.

 |
| Chave estrangeira | **Idêntica** ao nome da coluna referenciada (`veiculos.cliente_id` referencia `clientes.cliente_id`) | Estabelece clareza imediata e rastreabilidade nos relacionamentos antes mesmo da leitura das DDLs.

 |
| Nomes de colunas | Descritivos e semânticos (`preco_custo`, `preco_venda`, `tempo_estimado_min`) | Explicita a unidade de medida e o significado do dado, evitando interpretações incorretas.

 |

## 4. Entidades e Esquema Lógico Detalhado

O banco é estruturado em 15 tabelas interdependentes:

| Entidade (Tabela) | Descrição e Papel no Domínio | Colunas e Tipagem Principal | Chaves e Restrições |
| --- | --- | --- | --- |
| `clientes` | Armazena dados de proprietários de veículos.

 | `cliente_id` (PK), `nome`, `cpf_cnpj`, `telefone`, `email`, `endereco`, `data_cadastro`, `ativo`<br> | `uq_clientes_cpf_cnpj` (UNIQUE)

 |
| `veiculos` | Veículos cadastrados, vinculados a um cliente.

 | `veiculo_id` (PK), `placa`, `marca`, `modelo`, `ano_fabricacao`, `ano_modelo`, `cor`, `quilometragem`, `cliente_id` (FK)

 | `uq_veiculos_placa` (UNIQUE), FK -> `clientes`<br> |
| `tipos_funcionario` | Cargos e atribuições da oficina.

 | `tipo_funcionario_id` (PK), `descricao`<br> | `uq_tipos_funcionario_descricao` (UNIQUE)

 |
| `funcionarios` | Quadro funcional da oficina, com controle ativo/inativo.

 | `funcionario_id` (PK), `nome`, `cpf`, `telefone`, `data_admissao`, `salario`, `ativo`, `tipo_funcionario_id` (FK)

 | `uq_funcionarios_cpf` (UNIQUE), FK -> `tipos_funcionario`<br> |
| `fornecedores` | Fabricantes e distribuidores de autopeças.

 | `fornecedor_id` (PK), `razao_social`, `cnpj`, `telefone`, `email`, `endereco`<br> | `uq_fornecedores_cnpj` (UNIQUE)

 |
| `categorias_peca` | Agrupamento funcional das peças.

 | `categoria_peca_id` (PK), `descricao`<br> | `uq_categorias_peca_descricao` (UNIQUE)

 |
| `pecas` | Catálogo de peças com preços e fornecedores.

 | `peca_id` (PK), `nome`, `descricao`, `preco_custo`, `preco_venda`, `unidade_medida`, `categoria_peca_id` (FK), `fornecedor_id` (FK)

 | FK -> `categorias_peca`, FK -> `fornecedores`<br> |
| `estoques` | Controle do nível de inventário atual e mínimo.

 | `estoque_id` (PK), `peca_id` (FK, UNIQUE), `quantidade_atual`, `quantidade_minima`, `localizacao`, `data_atualizacao`<br> | `uq_estoques_peca` (UNIQUE 1:1), FK -> `pecas` (CASCADE)

 |
| `movimentacoes_estoque` | Registro cronológico auditável de entradas e saídas.

 | `movimentacao_estoque_id` (PK), `peca_id` (FK), `tipo_movimentacao`, `quantidade`, `data_movimentacao`, `observacao`<br> | CHECK (`tipo_movimentacao` IN ('ENTRADA','SAIDA')), FK -> `pecas` (CASCADE)

 |
| `servicos` | Mão de obra prestada com tempo padrão estimado.

 | `servico_id` (PK), `nome`, `descricao`, `valor`, `tempo_estimado_min`<br> | PK `servico_id`<br> |
| `formas_pagamento` | Modalidades de pagamento aceitas.

 | `forma_pagamento_id` (PK), `descricao`<br> | `uq_formas_pagamento_descricao` (UNIQUE)

 |
| `ordens_servico` | Entidade transacional central da manutenção.

 | `ordem_servico_id` (PK), `cliente_id` (FK), `veiculo_id` (FK), `funcionario_id` (FK), `data_abertura`, `data_previsao`, `data_conclusao`, `status`, `valor_total`, `observacoes`<br> | CHECK (`status` IN ('ABERTA','EM_ANDAMENTO','CONCLUIDA','CANCELADA')), FKs -> `clientes`, `veiculos`, `funcionarios`<br> |
| `ordens_servico_pecas` | Relação associativa contendo as peças faturadas na OS.

 | `ordem_servico_peca_id` (PK), `ordem_servico_id` (FK), `peca_id` (FK), `quantidade`, `preco_unitario`<br> | FK -> `ordens_servico` (CASCADE), FK -> `pecas` (RESTRICT)

 |
| `ordens_servico_servicos` | Relação associativa detalhando a mão de obra da OS.

 | `ordem_servico_servico_id` (PK), `ordem_servico_id` (FK), `servico_id` (FK), `funcionario_id` (FK), `valor_cobrado`<br> | FK -> `ordens_servico` (CASCADE), FK -> `servicos` (RESTRICT), FK -> `funcionarios` (RESTRICT)

 |
| `pagamentos` | Quitações financeiras das ordens de serviço.

 | `pagamento_id` (PK), `ordem_servico_id` (FK), `forma_pagamento_id` (FK), `valor`, `data_pagamento`, `parcelas`<br> | FK -> `ordens_servico` (CASCADE), FK -> `formas_pagamento` (RESTRICT)

 |

## 5. Integridade Referencial, Restrições e Regras de Negócio

1. **Políticas de Integridade Referencial (`ON DELETE`):**
* **`CASCADE`**: Aplicado exclusivamente onde o ciclo de vida do registro dependente é estritamente atrelado ao registro pai.


* Se uma ordem de serviço for removida, seus itens associados (`ordens_servico_pecas`, `ordens_servico_servicos`) e recebimentos vinculados (`pagamentos`) são excluídos automaticamente.


* Se uma peça for excluída da base, seu registro de estoque (`estoques`) e movimentações (`movimentacoes_estoque`) são limpos.




* **`RESTRICT`**: Protege cadastros mestres basilares (`clientes`, `veiculos`, `funcionarios`, `servicos`, `fornecedores`, `categorias_peca`, `formas_pagamento`). Um registro mestre não pode ser removido se possuir vínculos históricos, prevenindo orfandade e perda de histórico contábil/fiscal.




2. **Unicidade e Chaves Alternativas (`UNIQUE`):**
* `clientes.cpf_cnpj`: Garante que cada cliente possua apenas um cadastro ativo no sistema.


* `funcionarios.cpf`: Impede duplicidade cadastral de colaboradores.


* `veiculos.placa`: Identificação veicular única por padrão nacional.


* `fornecedores.cnpj`: Registro empresarial unívoco.


* `estoques.peca_id`: Assegura cardinalidade 1:1 estrita entre o catálogo de peças e seu registro de saldo de inventário.


* Campos descritivos (`tipos_funcionario.descricao`, `formas_pagamento.descricao`, `categorias_peca.descricao`): Bloqueiam cadastros duplicados de tabelas de domínio.




3. **Restrições de Validação de Domínio (`CHECK`):**
* `ordens_servico.status`: Restrito a `'ABERTA'`, `'EM_ANDAMENTO'`, `'CONCLUIDA'`, `'CANCELADA'`.


* `movimentacoes_estoque.tipo_movimentacao`: Restrito a `'ENTRADA'`, `'SAIDA'`.





## 6. Mapeamento de Cardinalidades e Relacionamentos

* **`clientes` (1) ─── (N) `veiculos**`: Um cliente pode possuir múltiplos veículos cadastrados, mas cada veículo pertence a um cliente específico.


* **`veiculos` (1) ─── (N) `ordens_servico**`: Um veículo pode gerar múltiplas passagens pela oficina ao longo de seu ciclo de vida.


* **`tipos_funcionario` (1) ─── (N) `funcionarios**`: Cada funcionário possui uma função/cargo definido.


* **`categorias_peca` (1) ─── (N) `pecas**`: Uma categoria agrupa múltiplos produtos.


* **`fornecedores` (1) ─── (N) `pecas**`: Cada peça do catálogo possui um fornecedor primário associado.


* **`pecas` (1) ─── (1) `estoques**`: Cada item cadastrado possui exatamente uma ficha de controle de saldo e estoque mínimo.


* **`pecas` (1) ─── (N) `movimentacoes_estoque**`: Cada produto registra N movimentações históricas.


* **`ordens_servico` (N) ─── (M) `pecas**`: Resolvido via associativa `ordens_servico_pecas` (contendo quantidade aplicada e preço praticado).


* **`ordens_servico` (N) ─── (M) `servicos**`: Resolvido via associativa `ordens_servico_servicos` (incluindo o mecânico executor e o valor cobrado).


* **`ordens_servico` (1) ─── (N) `pagamentos**`: Uma OS pode receber pagamentos em uma ou mais parcelas/transações.


* **`formas_pagamento` (1) ─── (N) `pagamentos**`: Cada transação de pagamento utiliza uma modalidade cadastrada.



## 7. Dados e Volume Populado no Sistema

A base de dados conta com um conjunto completo de dados em produção para testes e validações:

* **Clientes**: 30 registros (pessoas físicas com CPF e empresas com CNPJ).


* **Veículos**: 32 registros com placas reais, diversidade de marcas, anos de modelo e quilometragens.


* **Tipos de Funcionário**: 5 cargos base (Mecânico, Atendente, Gerente, Caixa, Auxiliar de Estoque).


* **Funcionários**: 30 colaboradores cadastrados, com salários, datas de admissão e status (`ativo`).


* **Fornecedores**: 4 distribuidoras regionais de autopeças.


* **Categorias de Peças**: 8 categorias operacionais.


* **Catálogo de Peças**: 32 itens com preços de custo e de venda definidos.


* **Estoque & Movimentações**: 32 fichas de inventário e 36 movimentações detalhadas de entrada e saída.


* **Catálogo de Serviços**: 30 procedimentos padronizados com tempos médios estimados de execução.


* **Formas de Pagamento**: 5 opções de recebimento.


* **Ordens de Serviço**: 34 ordens de serviço simulando diversos cenários do negócio.


* **Itens e Serviços em OS**: 53 lançamentos de peças e 48 execções de serviços com mecânicos atribuídos.


* **Pagamentos**: 30 transações financeiras registradas.



## 8. Estrutura do DDL Completo (Scripts SQL)

```sql
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

CREATE TABLE tipos_funcionario (
    tipo_funcionario_id INT PRIMARY KEY,
    descricao            VARCHAR(50) NOT NULL,
    CONSTRAINT uq_tipos_funcionario_descricao UNIQUE (descricao)
);

CREATE TABLE formas_pagamento (
    forma_pagamento_id  INT PRIMARY KEY,
    descricao           VARCHAR(30) NOT NULL,
    CONSTRAINT uq_formas_pagamento_descricao UNIQUE (descricao)
);

CREATE TABLE categorias_peca (
    categoria_peca_id  INT PRIMARY KEY,
    descricao          VARCHAR(80) NOT NULL,
    CONSTRAINT uq_categorias_peca_descricao UNIQUE (descricao)
);

CREATE TABLE fornecedores (
    fornecedor_id   INT PRIMARY KEY,
    razao_social    VARCHAR(150) NOT NULL,
    cnpj            VARCHAR(20) NOT NULL,
    telefone        VARCHAR(20),
    email           VARCHAR(150),
    endereco        VARCHAR(200),
    CONSTRAINT uq_fornecedores_cnpj UNIQUE (cnpj)
);

CREATE TABLE servicos (
    servico_id          INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    valor               DECIMAL(10,2) NOT NULL,
    tempo_estimado_min  INT
);

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

CREATE TABLE pecas (
    peca_id             INT PRIMARY KEY,
    nome                VARCHAR(150) NOT NULL,
    descricao           VARCHAR(255),
    preco_custo         DECIMAL(10,2) NOT NULL,
    preco_venda         DECIMAL(10,2) NOT NULL,
    unidade_medida      VARCHAR(10) NOT NULL,
    categoria_peca_id   INT NOT NULL,
    fornecedor_id       INT NOT NULL,
    CONSTRAINT fk_pecas_categoria
        FOREIGN KEY (categoria_peca_id)
        REFERENCES categorias_peca (categoria_peca_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pecas_fornecedor
        FOREIGN KEY (fornecedor_id)
        REFERENCES fornecedores (fornecedor_id)
        ON DELETE RESTRICT
);

CREATE TABLE estoques (
    estoque_id          INT PRIMARY KEY,
    peca_id             INT NOT NULL,
    quantidade_atual    INT NOT NULL DEFAULT 0,
    quantidade_minima   INT NOT NULL DEFAULT 0,
    localizacao         VARCHAR(50),
    data_atualizacao    DATE,
    CONSTRAINT uq_estoques_peca UNIQUE (peca_id),
    CONSTRAINT fk_estoques_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE CASCADE
);

CREATE TABLE movimentacoes_estoque (
    movimentacao_estoque_id INT PRIMARY KEY,
    peca_id                 INT NOT NULL,
    tipo_movimentacao       VARCHAR(10) NOT NULL,
    quantidade              INT NOT NULL,
    data_movimentacao       TIMESTAMP NOT NULL,
    observacao              VARCHAR(255),
    CONSTRAINT ck_movimentacoes_tipo
        CHECK (tipo_movimentacao IN ('ENTRADA','SAIDA')),
    CONSTRAINT fk_movimentacoes_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE CASCADE
);

CREATE TABLE ordens_servico (
    ordem_servico_id    INT PRIMARY KEY,
    cliente_id          INT NOT NULL,
    veiculo_id          INT NOT NULL,
    funcionario_id      INT NOT NULL,
    data_abertura       TIMESTAMP NOT NULL,
    data_previsao       DATE,
    data_conclusao      TIMESTAMP,
    status              VARCHAR(20) NOT NULL,
    valor_total         DECIMAL(10,2) NOT NULL DEFAULT 0,
    observacoes         VARCHAR(255),
    CONSTRAINT ck_ordens_servico_status
        CHECK (status IN ('ABERTA','EM_ANDAMENTO','CONCLUIDA','CANCELADA')),
    CONSTRAINT fk_ordens_servico_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes (cliente_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_ordens_servico_veiculo
        FOREIGN KEY (veiculo_id)
        REFERENCES veiculos (veiculo_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_ordens_servico_funcionario
        FOREIGN KEY (funcionario_id)
        REFERENCES funcionarios (funcionario_id)
        ON DELETE RESTRICT
);

CREATE TABLE ordens_servico_pecas (
    ordem_servico_peca_id  INT PRIMARY KEY,
    ordem_servico_id       INT NOT NULL,
    peca_id                INT NOT NULL,
    quantidade             INT NOT NULL,
    preco_unitario         DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_osp_ordem_servico
        FOREIGN KEY (ordem_servico_id)
        REFERENCES ordens_servico (ordem_servico_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_osp_peca
        FOREIGN KEY (peca_id)
        REFERENCES pecas (peca_id)
        ON DELETE RESTRICT
);

CREATE TABLE ordens_servico_servicos (
    ordem_servico_servico_id   INT PRIMARY KEY,
    ordem_servico_id           INT NOT NULL,
    servico_id                 INT NOT NULL,
    funcionario_id             INT NOT NULL,
    valor_cobrado              DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_oss_ordem_servico
        FOREIGN KEY (ordem_servico_id)
        REFERENCES ordens_servico (ordem_servico_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_oss_servico
        FOREIGN KEY (servico_id)
        REFERENCES servicos (servico_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_oss_funcionario
        FOREIGN KEY (funcionario_id)
        REFERENCES funcionarios (funcionario_id)
        ON DELETE RESTRICT
);

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

```

## 9. Organização dos arquivos

```
/ddl   → scripts DDL de criação de tabelas, chaves, índices e constraints + 00_dropar_tabelas.sql
/dml   → scripts DML de carga de dados (INSERTs de clientes, veículos, peças, serviços, OS e pagamentos)
/dql   → scripts DQL de consultas analíticas e operacionais (SELECTs com JOINs, agregações e filtros)
/docs  → documentação de modelagem e arquitetura conceitual/lógica do banco

```
