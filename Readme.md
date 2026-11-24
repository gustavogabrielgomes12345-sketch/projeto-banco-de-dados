# Banco de Dados — Oficina Mecânica

Documentação técnica e vitrine de arquitetura do banco de dados relacional projetado para a gestão operacional, técnica e financeira de uma **Oficina Mecânica** em **PostgreSQL**.

Este repositório reúne a modelagem completa do banco, englobando estrutura de tabelas e relacionamentos (**DDL**), rotinas e regras de negócio (**PSM**), automações e visões gerenciais (**Triggers e Views**), carga de dados para simulação (**DML**) e consultas de inteligência de negócio (**DQL**).

---

## Arquitetura da Solução e Regras de Negócio

O sistema integra os principais setores de uma oficina automotiva em um fluxo contínuo e rastreável:

1. **Atendimento e Clientes:** Cadastro de clientes (Pessoa Física ou Jurídica) e veículos (com placa, marca, modelo, ano, cor, quilometragem e vínculo ao proprietário).
2. **Equipe Operacional:** Organização de cargos e colaboradores, identificando atendentes, mecânicos responsáveis e profissionais envolvidos nos serviços.
3. **Gestão de Insumos e Fornecedores:** Categorização de peças, cadastro de fornecedores, controle de saldo físico, reservas e movimentações de entrada e saída, além da categorização de serviços.
4. **Ordens de Serviço (OS):** Núcleo operacional que conecta clientes, veículos, equipe, peças aplicadas, mão de obra e etapas do atendimento.
5. **Fluxo Financeiro:** Geração de cobranças, controle de faturamento, aplicação de descontos e juros, parcelamento, formas de pagamento (Dinheiro, Pix, Cartão de Débito, Cartão de Crédito, Boleto) e acompanhamento de inadimplência.

---

## Estrutura das Tabelas (DDL)

A modelagem conta com **18 tabelas** organizadas por domínio funcional e integridade referencial:

### 🔹 Módulo de Clientes e Veículos
- **`clientes`**: Dados cadastrais (nome, CPF/CNPJ, contato, endereço, data de cadastro e status ativo).
- **`veiculos`**: Frota vinculada aos clientes, com placa, marca, modelo, anos de fabricação/modelo, cor e quilometragem.

### 🔹 Módulo de Recursos Humanos
- **`tipos_funcionario`**: Cargos e funções da equipe (Mecânico, Atendente, Gerente, Caixa).
- **`funcionarios`**: Dados da equipe interna, data de admissão, salário, status ativo e cargo associado.

### 🔹 Módulo de Peças, Serviços e Estoque
- **`fornecedores`**: Empresas parceiras de autopeças.
- **`categorias_peca`**: Classificação técnica das peças (Motor, Freios, Suspensão, Elétrica, Filtros e Fluidos).
- **`pecas`**: Catálogo de peças com preço de custo, preço de venda, unidade de medida, categoria e fornecedor.
- **`estoques`**: Saldo físico atual, quantidade reservada, estoque mínimo de segurança, localização no almoxarifado e data de atualização.
- **`movimentacoes_estoque`**: Histórico de entradas (incluindo fornecedor, nota fiscal e preço unitário) e saídas de peças.
- **`log_preco_pecas`**: Histórico de alterações no preço de venda das peças, com valores anterior e novo, data e usuário.
- **`categorias_servico`**: Classificação dos tipos de serviço (Preventiva, Freios e Suspensão, Elétrica).
- **`servicos`**: Catálogo de serviços de mão de obra com valor padrão, tempo estimado e categoria.

### 🔹 Módulo de Ordens de Serviço
- **`ordens_servico`**: Registro principal da OS com cliente, veículo, mecânico, atendente, datas (abertura, previsão, conclusão), status, valores de peças/mão de obra/total e observações.
- **`ordens_servico_pecas`**: Itens de peça utilizados em cada OS, com quantidade e preço unitário.
- **`ordens_servico_servicos`**: Serviços executados em cada OS, com responsável, valor cobrado e desconto concedido.

### 🔹 Módulo Financeiro
- **`formas_pagamento`**: Modalidades de pagamento disponíveis (Dinheiro, Pix, Cartão de Débito, Cartão de Crédito, Boleto).
- **`cobrancas`**: Controle de valores a receber por OS, com datas de emissão e vencimento, valor e status.
- **`pagamentos`**: Registro de pagamentos efetuados, contemplando valor, juros, descontos, data e número de parcelas.

---

## Rotinas e Regras de Negócio (PSM)

A camada de **PSM (Functions e Procedures)** encapsula operações e cálculos recorrentes diretamente no banco:

### ⚙️ Functions (`fc_*`)
- **`fc_calcular_valor_total_os`**: Calcula o valor total de uma OS somando peças e serviços.
- **`fc_total_gasto_cliente`**: Consolida o quanto um cliente já gastou em ordens de serviço concluídas, finalizadas ou pagas.
- **`fc_verificar_peca_estoque_critico`**: Indica se o saldo disponível de uma peça (descontando reservas) está abaixo do estoque mínimo.
- **`fc_produtividade_mensal_mecanico`**: Retorna a quantidade de OS concluídas e o valor de mão de obra de um mecânico em determinado mês e ano.
- **`fc_faturamento_por_categoria_servico`**: Calcula o faturamento de serviços por categoria dentro de um período de datas.

### 🛠️ Procedures (`sp_*`)
- **`sp_abrir_ordem_servico`**: Valida cliente ativo, veículo do cliente e mecânico/atendente ativos, abrindo uma nova OS e retornando seu identificador.
- **`sp_adicionar_peca_ordem_servico`**: Valida status da OS e disponibilidade em estoque, adiciona ou atualiza o item na OS e recalcula o total de peças.
- **`sp_finalizar_ordem_servico`**: Consolida os valores da OS, atualiza o status para `FINALIZADA`, registra a data de conclusão e gera a cobrança correspondente.
- **`sp_registrar_pagamento_os`**: Calcula descontos à vista ou extras, juros de parcelamento ou atraso conforme regras de pagamento, registra a liquidação e atualiza cobrança e OS para `PAGA`.
- **`sp_dar_entrada_estoque_fornecedor`**: Registra entrada de mercadorias por nota fiscal (com itens em JSON), atualizando saldo em estoque, custo da peça e histórico de movimentações.

---

## Automações e Visões Gerenciais (Triggers e Views)

### 🔔 Triggers (`tg_*`)
- **`tg_reservar_estoque_peca_os`**: Gerencia a reserva de peças no estoque quando itens são incluídos, alterados ou removidos em OS em andamento.
- **`tg_impedir_finalizacao_os_sem_servico`**: Bloqueia a finalização de uma OS que não possua ao menos uma peça ou um serviço vinculado.
- **`tg_dar_baixa_definitiva_estoque_conclusao_os`**: Efetiva a baixa no estoque, libera reservas e lança movimentação de saída ao concluir/finalizar uma OS.
- **`tg_auditoria_reajuste_preco_pecas`**: Registra automaticamente na tabela de auditoria toda alteração no preço de venda de uma peça.
- **`tg_impedir_exclusao_cliente_com_os_aberta`**: Impede a exclusão de clientes que possuam ordens de serviço em aberto.

### 📊 Views (`vw_*`)
- **`vw_relatorio_faturamento_os`**: Consolidado financeiro das OS concluídas, finalizadas ou pagas, com peças, mão de obra, descontos, forma de pagamento, parcelas e valor pago.
- **`vw_estoque_pecas_necessidade_reposicao`**: Visão de compras mostrando saldo atual, reservado, disponível, mínimo, quantidade a repor e custo estimado de reposição.
- **`vw_produtividade_mecanicos_mes`**: Acompanhamento mensal por mecânico com quantidade de OS atendidas, mão de obra gerada e tempo médio de execução em horas.
- **`vw_historico_manutencoes_veiculo`**: Linha do tempo unificada de serviços e peças aplicados em cada veículo.
- **`vw_inadimplencia_contas_receber`**: Painel de valores pendentes de pagamento, com vencimento, dias em atraso, situação e total devido por cliente.

---

## Carga e Teste de Dados (DML)

O script de carga inicial popula o banco de forma ordenada para simular cenários completos de operação:

- **Clientes e Frota:** Clientes ativos e inativos, com múltiplos veículos cadastrados.
- **Equipe e Catálogos:** Cargos, funcionários, fornecedores, categorias de peças e serviços, peças, estoques e formas de pagamento.
- **Operação e Financeiro:** Ordens de serviço em diferentes estágios (`ABERTA`, `EM_ANDAMENTO`, `CONCLUIDA`), itens de peças e serviços, movimentações de estoque, pagamento registrado e cobrança pendente para testes de gestão e inadimplência.

---

## Consultas e Relatórios de Negócio (DQL)

O arquivo de consultas reúne **20 relatórios SQL** voltados à análise operacional, comercial e financeira:

1. **Faturamento por Cliente:** Total faturado por cliente em OS concluídas.
2. **Curva de Peças:** Total de saídas por peça comparado ao saldo atual em estoque.
3. **Desempenho dos Mecânicos:** Valor total de mão de obra gerado por mecânico.
4. **OS sem Pagamento:** Ordens de serviço concluídas ainda sem pagamento registrado.
5. **Peças Abaixo do Estoque Mínimo:** Itens que precisam de reposição e quantidade necessária.
6. **Ticket Médio por Marca:** Valor médio das OS concluídas agrupado por marca do veículo.
7. **Tempo Médio de Execução:** Média de horas entre abertura e conclusão das OS concluídas por mecânico.
8. **Peças Nunca Utilizadas:** Peças cadastradas que ainda não entraram em nenhuma OS.
9. **Margem por Peça:** Diferença nominal e percentual entre preço de venda e preço de custo.
10. **Serviços Mais Solicitados:** Top 5 serviços com maior número de solicitações.
11. **Entradas de Estoque por Fornecedor:** Quantidade total de peças recebidas por fornecedor.
12. **Veículos com Muitas OS:** Veículos com mais de 3 ordens de serviço no ano corrente.
13. **Faturamento por Forma de Pagamento:** Total recebido agrupado por meio de pagamento.
14. **OS com Maior Valor de Peças:** Ordens de serviço onde o valor das peças supera o da mão de obra.
15. **Última Revisão:** Data da última OS concluída para cada veículo.
16. **Rotatividade de Estoque:** Volume total movimentado por peça.
17. **Inadimplência:** Soma do valor das OS concluídas sem pagamento registrado.
18. **Mecânicos sem OS:** Mecânicos sem abertura de OS na data atual.
19. **Descontos Concedidos:** Soma total de descontos aplicados nos serviços.
20. **Relatório Consolidado de OS:** Visão geral com cliente, veículo, mecânico responsável, status e valor total.

---

## Estrutura de Arquivos do Repositório

```text
banco-de-dados-relacional-consultas/
├── DDL´s.sql          # Estrutura das tabelas, chaves e relacionamentos (18 tabelas)
├── PSM.sql            # Functions e Procedures de negócio
├── Triggers_Views.sql # Triggers de automação/integridade e Views gerenciais
├── DML´s.sql          # Carga inicial de dados para simulação e testes
├── DQL´s.sql          # 20 consultas de relatórios e indicadores gerenciais
└── README.md          # Documentação do projeto
