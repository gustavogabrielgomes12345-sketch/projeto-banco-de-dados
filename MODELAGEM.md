# Modelagem de Banco de Dados — Oficina Mecânica

## 1. Domínio do sistema

O sistema escolhido foi o de uma **oficina mecânica**. A ideia é controlar os principais dados da oficina, como clientes, veículos, ordens de serviço, serviços realizados, peças, estoque, fornecedores, funcionários e pagamentos.

## 2. Justificativa do domínio escolhido

Escolhemos uma oficina mecânica porque é um tipo de sistema que possui várias informações que precisam se relacionar e, ao mesmo tempo, é fácil de entender. Com esse tema conseguimos trabalhar diferentes situações de banco de dados, como:

- Relacionamento entre cliente, veículo e ordem de serviço, permitindo trabalhar cardinalidades como 1:N e N:N.
- Controle de estoque das peças, registrando entradas, saídas, quantidade disponível e estoque mínimo.
- Uso de tabelas associativas para ligar as ordens de serviço às peças utilizadas e aos serviços realizados.
- Registro do andamento das ordens de serviço e também das movimentações realizadas no estoque.
- É um tema conhecido pelo grupo, então fica mais fácil entender como o sistema funcionaria na prática e discutir as regras do negócio.

## 3. Padrão de nomenclatura adotado

Baseado na leitura obrigatória
([Database Naming Standards — dev.to/ovid](https://dev.to/ovid/database-naming-standards-2061)),
decidimos utilizar os seguintes padrões:

| Decisão | Padrão escolhido | Motivo (segundo o artigo) |
|---|---|---|
| Case | `snake_case` (underscore) | Evita ambiguidade (`under_value` × `undervalue`) e é mais acessível/legível. |
| Nome de tabela | **Plural** (`clientes`, `veiculos`) | Reduz colisão com palavras reservadas do SQL (`user`, `order`, etc.) e representa uma coleção de registros. |
| Nome da chave primária | **Nunca `id` sozinho** — sempre por extenso: `cliente_id`, `veiculo_id`, `peca_id` | Evita joins ambíguos como `origin.id = thread.id`; o erro fica visível numa única linha de SQL. |
| Nome de futuras chaves estrangeiras | **Idêntico** ao nome da coluna referenciada (`veiculos.cliente_id` refere `clientes.cliente_id`) | Deixa o relacionamento óbvio antes mesmo de existir a constraint de FK. |
| Nomes de coluna | Descritivos, nunca genéricos (`fahrenheit` em vez de `temperatura`, `preco_venda` em vez de `valor`) | Evita ambiguidade de unidade/sentido. |

> Observação: mesmo que alguns exemplos utilizem nomes de tabelas no singular e apenas `id` como chave, decidimos manter as tabelas no plural e identificar a chave pelo nome da entidade, como `cliente_id`. Assim, fica mais fácil saber a qual tabela cada campo pertence.

## 4. Entidades identificadas

| Entidade (tabela) | Papel no domínio |
|---|---|
| `clientes` | Pessoas que trazem veículos para manutenção. |
| `veiculos` | Veículos pertencentes a um cliente. |
| `tipos_funcionario` | Cargo/função do funcionário (mecânico, atendente, gerente...). |
| `funcionarios` | Equipe da oficina. |
| `fornecedores` | Empresas que fornecem peças. |
| `categorias_peca` | Categoria/classificação das peças (motor, freio, elétrica...). |
| `pecas` | Catálogo de peças/produtos vendidos ou usados nos serviços. |
| `estoques` | Saldo atual e mínimo de cada peça. |
| `movimentacoes_estoque` | Histórico de entradas/saídas de peças no estoque. |
| `servicos` | Catálogo de serviços prestados (troca de óleo, alinhamento...). |
| `ordens_servico` | Ordem de serviço aberta para um veículo/cliente. |
| `ordens_servico_pecas` | Peças utilizadas em uma ordem de serviço (associativa). |
| `ordens_servico_servicos` | Serviços realizados em uma ordem de serviço (associativa). |
| `formas_pagamento` | Formas de pagamento aceitas (dinheiro, pix, cartão...). |
| `pagamentos` | Pagamentos recebidos referentes a uma ordem de serviço. |

## 5. Observação sobre chaves estrangeiras

Nesta etapa do trabalho ainda não foram adicionadas as **FOREIGN KEY**. Os campos que futuramente serão usados como chaves estrangeiras já foram criados, como `veiculos.cliente_id`, mas as constraints serão adicionadas em uma próxima etapa.

## 6. Organização dos arquivos

```
/ddl   → scripts de criação das tabelas (CREATE TABLE)
/dml   → scripts de manipulação de dados (INSERT de exemplo)
/dql   → scripts de consulta (SELECT) para os principais casos de uso
/docs  → esta documentação
```
