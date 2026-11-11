## 📝 4. Documentação Principal (`README.md`)

```markdown
# Simulado Prático Integrado — Computação em Nuvem

- **Aluno:** Igor Soares]
- **Turma:** TADS - 4 Semestre
- **Data:** 11/11/2026
- **Professora:** Simone Tatiane do Canto

## Resumo do Trabalho
Este repositório contém a infraestrutura como código (manifestos Kubernetes) e as evidências de validação para a publicação e gerenciamento resiliente da aplicação web **Simulado Cloud** em um cluster Kubernetes de dois nós no ambiente Killercoda. O projeto abrange configuração externalizada via ConfigMaps e Secrets, controle de acesso refinado (RBAC), sondagens de saúde (*probes*), estratégias de escala, atualizações com gerenciamento de rollout/rollback e tarefas automatizadas com Jobs/CronJobs.

---

## Questionário Teórico

### 1. Qual é a diferença entre contêiner, Pod e Deployment?
- **Contêiner:** É a menor unidade de execução isolada (geralmente usando namespaces e cgroups do Linux), empacotando uma aplicação e suas dependências diretas.
- **Pod:** É a menor unidade lógica do Kubernetes. Um Pod encapsula um ou mais contêineres que compartilham recursos de rede (mesmo IP e portas) e armazenamento.
- **Deployment:** É um objeto de nível superior (controlador) que gerencia um conjunto de Pods idênticos, garantindo a quantidade desejada de réplicas em execução, além de gerenciar atualizações controladas (*rollouts*) e reversões (*rollbacks*).

### 2. Por que ConfigMap e Secret têm finalidades diferentes?
- **ConfigMap:** É projetado para armazenar dados de configuração não confidenciais em formato de texto simples (pares chave-valor), facilitando a desacoplamento de parâmetros de configuração do código da aplicação.
- **Secret:** Possui o mesmo propósito de armazenamento de dados arbitrários, porém é otimizado para dados sensíveis (como senhas, tokens OAuth, chaves SSH). Embora codificados por padrão em Base64 (o que não é criptografia forte), os Secrets permitem maior controle de acesso restrito, criptografia em repouso opcional e mascaramento em logs/exibições dependendo da política do cluster.

### 3. Qual a diferença entre readiness e liveness?
- **ReadinessProbe (Sonda de Prontidão):** Informa ao Kubernetes quando o contêiner está pronto para começar a receber tráfego de rede (tráfego de serviços). Se falhar, o Pod é removido dos endpoints do Service até se recuperar.
- **LivenessProbe (Sonda de Vivacidade):** Informa ao Kubernetes se o contêiner está saudável e funcionando corretamente. Se falhar repetidamente, o Kubernetes encerra e reinicia o contêiner afetado.

### 4. O que ocorreu após a exclusão do Pod?
O controlador do Deployment detectou que o número atual de réplicas em execução ficou abaixo do especificado (passou de 2 para 1). Imediatamente, o ReplicaSet gerenciado pelo Deployment provisionou um novo Pod com um nome e IP novos para restaurar o estado desejado de 2 réplicas ativas, demonstrando a propriedade de autorrecuperação (*self-healing*) do Kubernetes.

### 5. O que o rollback recuperou? A página voltou à versão 1? Explique.
O `kubectl rollout undo` recuperou a **revisão anterior da especificação do Deployment** (revertendo a imagem inválida de volta para `nginx:alpine`). No entanto, **o conteúdo do ConfigMap não foi revertido automaticamente**, pois o ConfigMap é um objeto independente desacoplado do ciclo de revisão do Deployment. Portanto, a aplicação voltou a funcionar, mas continuou exibindo a **Versão 2** do arquivo HTML contida no ConfigMap ativo.

### 6. Qual a diferença entre Deployment, Job e CronJob?
- **Deployment:** Gerencia cargas de trabalho de execução contínua (serviços web, APIs), mantendo um número fixo de réplicas ativas permanentemente.
- **Job:** Cria um ou mais Pods para executar uma tarefa pontual até que ela seja concluída com sucesso (término com código de saída 0), após o qual os Pods param.
- **CronJob:** Gerencia a execução de Jobs de forma recorrente e agendada, seguindo uma sintaxe de cronograma padrão (ex: a cada 5 minutos).
