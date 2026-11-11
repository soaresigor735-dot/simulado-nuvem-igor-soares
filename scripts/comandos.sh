#!/bin/bash
# =====================================================================
# SIMULADO PRÁTICO INTEGRADO — COMPUTAÇÃO EM NUVEM
# Script consolidador de comandos executados no Killercoda
# =====================================================================

# Etapa 1 — Preparação do cluster
kubectl get nodes
kubectl create namespace simulado-nuvem
kubectl get namespace simulado-nuvem

# Etapa 2 — Configuração e segurança
kubectl apply -f manifests/01-configmap-v1.yaml
kubectl -n simulado-nuvem create secret generic senha-app --from-literal=token=valor-ficticio-2026
kubectl apply -f manifests/03-rbac.yaml

# Validação RBAC
kubectl auth can-i list pods -n simulado-nuvem --as=system:serviceaccount:simulado-nuvem:leitor-web
kubectl auth can-i delete pods -n simulado-nuvem --as=system:serviceaccount:simulado-nuvem:leitor-web

# Etapa 3 — Aplicação e disponibilidade
kubectl apply -f manifests/04-web.yaml
kubectl -n simulado-nuvem rollout status deployment/web
kubectl -n simulado-nuvem get deployment,pods,service

# Etapa 4 — Teste da página e diagnóstico
kubectl -n simulado-nuvem run cliente --image=busybox:1.36 --restart=Never --command -- sleep 3600
kubectl -n simulado-nuvem wait --for=condition=Ready pod/cliente --timeout=90s
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web
kubectl -n simulado-nuvem describe deployment web
kubectl -n simulado-nuvem logs deployment/web --tail=20

# Etapa 5 — Escala e autorrecuperação
kubectl -n simulado-nuvem scale deployment web --replicas=3
kubectl -n simulado-nuvem get pods -w
kubectl -n simulado-nuvem scale deployment web --replicas=2
# Simular falha destruindo um pod
kubectl -n simulado-nuvem delete pod -l app=web --field-selector=status.phase=Running --wait=false

# Etapa 6 — Atualização e rollback
kubectl apply -f manifests/02-configmap-v2.yaml
kubectl -n simulado-nuvem rollout restart deployment/web
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web

# Falha intencional de imagem
kubectl -n simulado-nuvem set image deployment/web nginx=nginx:tag-inexistente-simulado
kubectl -n simulado-nuvem rollout status deployment/web --timeout=30s
kubectl -n simulado-nuvem rollout undo deployment/web
kubectl -n simulado-nuvem exec cliente -- wget -qO- http://web

# Etapa 7 — Job e CronJob
kubectl apply -f manifests/05-cronjob.yaml
kubectl -n simulado-nuvem create job teste-web --from=cronjob/verifica-web
kubectl -n simulado-nuvem wait --for=condition=complete job/teste-web --timeout=120s
kubectl -n simulado-nuvem logs job/teste-web
