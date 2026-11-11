# Evidências do Simulado Prático - Computação em Nuvem

## 1. Cluster e Namespace
```bash
\$ kubectl get nodes
NAME     STATUS   ROLES           AGE   VERSION
node01   Ready    control-plane   12m   v1.28.0
node02   Ready    <none>          11m   v1.28.0

\$ kubectl create namespace simulado-nuvem
namespace/simulado-nuvem created
