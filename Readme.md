# Banco de Dados — Oficina Mecânica

Documentação técnica completa e guia de arquitetura do banco de dados relacional projetado para a gestão operacional, técnica e financeira de uma **Oficina Mecânica**. 

Este repositório contém a modelagem lógica e física do banco, englobando a definição de tabelas (DDL), carga de dados para testes (DML) e relatórios de inteligência de negócio (DQL).

---

## Arquitetura da Solução e Regras de Negócio

O sistema foi desenvolvido para integrar todos os setores de uma oficina automotiva em um único fluxo de informação:

1. **Atendimento e Clientes:** Cadastramento de clientes (Pessoa Física ou Jurídica) e de seus veículos (com histórico de placas, modelo, ano e quilometragem).
2. **Equipe Operacional:** Estruturação dos colaboradores e cargos, permitindo identificar os mecânicos responsáveis por cada serviço prestado.
3. **Gestão de Insumos e Fornecedores:** Mapeamento de autopeças por categoria, controle de fornecedores, monitoramento de localização no almoxarifado (prateleiras/corredores) e movimentações de entrada e saída.
4. **Ordens de Serviço (OS):** O núcleo do sistema, responsável por conectar clientes, veículos, mecânicos, peças utilizadas e mão de obra em uma única estrutura auditável.
5. **Fluxo Financeiro:** Controle de faturamento por ordem de serviço, aplicação de descontos, modalidades de pagamento (Pix, Cartão, Dinheiro) e controle de pendências.

---

## Estrutura das Tabelas (DDL)

A modelagem do banco de dados é composta por **15 tabelas**, organizadas de acordo com suas responsabilidades e relacionamentos:

### 🔹 Módulo de Clientes e Veículos
* **`clientes`**: Armazena os dados cadastrais (nome, CPF/CNPJ, contato e endereço). Possui um campo lógico para controle de cadastros ativos.
* **`veiculos`**: Armazena a frota cadastrada. Cada veículo está vinculado obrigatoriamente a um cliente (`cliente_id`).

### 🔹 Módulo de Recursos Humanos
* **`tipos_funcionario`**: Tabela de domínio que especifica as funções na empresa (Mecânico, Atendente, Gerente, Caixa).
* **`funcionarios`**: Registra os dados da equipe, salário base, data de admissão e a função associada (`tipo_funcionario_id`).

### 🔹 Módulo de Peças e Estoque
* **`fornecedores`**: Empresas parceiras responsáveis pelo fornecimento das peças.
* **`categorias_peca`**: Classificação técnica das peças (Motor, Freios, Suspensão, Elétrica, Filtros e Fluidos).
* **`pecas`**: Catálogo de itens com preço de custo, preço de venda recomendado, unidade de medida e vínculos com fornecedor e categoria.
* **`estoques`**: Posição atualizada do saldo físico de cada peça, limite mínimo de segurança e localização física no almoxarifado.
* **`movimentacoes_estoque`**: Histórico temporal de entradas (compras) e saídas (uso em serviços ou perdas).

### 🔹 Módulo de Serviços e Ordens de Serviço
* **`servicos`**: Catálogo de procedimentos de mão de obra disponíveis, incluindo tabela de preços padrão e tempo médio estimado em minutos.
* **`ordens_servico`**: Cabeçalho do atendimento, registrando datas de abertura, previsão e conclusão, mecânico responsável e o status (`ABERTA`, `EM_ANDAMENTO`, `CONCLUIDA`, `CANCELADA`).
* **`ordens_servico_pecas`**: Tabela associativa que detalha as peças e quantidades aplicadas em cada OS.
* **`ordens_servico_servicos`**: Tabela associativa que detalha os serviços executados em cada OS, permitindo registrar o valor cobrado e descontos concedidos.

### 🔹 Módulo Financeiro
* **`formas_pagamento`**: Cadastramento das opções aceitas na oficina (Dinheiro, Pix, Cartão de Crédito, Boleto).
* **`pagamentos`**: Registro das liquidações realizadas para cada ordem de serviço, informando valor pago, data da transação e número de parcelas.

---

## Carga e Teste de Dados (DML)

O script de povoamento (`dml/01_carga_dados.sql`) insere dados coerentes para simular o dia a dia da oficina e permitir a validação de cenários reais de negócio:

* **Relacionamentos Completos:** Clientes com múltiplos veículos associados.
* **Cenários Operacionais Variados:** Ordens de Serviço finalizadas, em andamento e abertas.
* **Alertas de Estoque:** Peças cadastradas com saldo atual abaixo do limite mínimo recomendado para testar os relatórios de reposição.
* **Análise Financeira:** OSs com pagamento confirmado e OSs concluídas sem pagamento registrado para validação de métricas de inadimplência.

---

## Consultas e Relatórios de Negócio (DQL)

O diretório `dql/oficina_mecanica.sql` reúne **20 consultas SQL** focadas em inteligência operacional e tomada de decisão:

1. **Faturamento por Cliente:** Soma total de valores faturados agrupados por cliente.
2. **Curva de Peças:** Quantidade total de saídas por peça confrontada com o saldo atual de estoque.
3. **Desempenho dos Mecânicos:** Faturamento acumulado gerado exclusivamente por mão de obra por cada mecânico.
4. **Ordens de Serviço sem Pagamento:** Identificação de serviços concluídos com pendência financeira.
5. **Peças Abaixo do Estoque Mínimo:** Relatório de reposição imediata para o setor de compras.
6. **Ticket Médio por Marca:** Análise do valor médio gasto em veículos de diferentes montadoras.
7. **Tempo Médio de Execução:** Cálculo da média de duração (em horas) entre a abertura e a conclusão do atendimento por mecânico.
8. **Peças Sem Movimentação:** Identificação de itens em estoque que nunca foram aplicados em nenhuma OS.
9. **Margem de Lucro por Peça:** Cálculo da margem bruta nominal e percentual de lucro sobre o custo de aquisição.
10. **Serviços Mais Solicitados:** Ranking das operações de mão de obra com maior demanda.
11. **Volume de Entradas por Fornecedor:** Total de peças adquiridas por empresa fornecedora.
12. **Frequência de Veículos:** Mapeamento de automóveis que deram entrada na oficina mais de 3 vezes no ano.
13. **Faturamento por Forma de Pagamento:** Distribuição da arrecadação por modalidade de pagamento.
14. **Análise de Custo de OS:** Filtro de atendimentos onde o custo das peças superou o valor da mão de obra.
15. **Histórico da Última Revisão:** Data do último atendimento concluído para cada veículo cadastrado.
16. **Rotatividade de Estoque:** Mapeamento do fluxo total (entradas + saídas) por item.
17. **Total de Inadimplência:** Somatório consolidado de valores devidos em ordens de serviço concluídas.
18. **Escala Diária de Mecânicos:** Identificação de profissionais sem ordens de serviço abertas na data atual.
19. **Total de Descontos Concedidos:** Levantamento do montante abatido nas negociações de serviços.
20. **Visão Consolidada de Atendimentos:** Relatório geral unindo cliente, veículo, mecânico responsável, status e valor final da OS.

---

## Estrutura de Arquivos do Repositório

```text
banco-de-dados-relacional-consultas/
├── DDL´s.sql        # Estrutura completa do banco de dados (15 tabelas)
├── DML´s.sql        # Povoamento com dados de teste
├── DQL´s.sql        # 20 Consultas de relatórios e métricas gerenciais
└── README.md        # Documentação técnica do projeto
