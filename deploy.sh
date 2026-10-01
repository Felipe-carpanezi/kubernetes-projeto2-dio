#!/usr/bin/env bash
# deploy.sh - substitui o pipeline GitLab CI (build + deploy) rodando localmente no Minikube
set -euo pipefail

echo "==> [1/5] Verificando o Minikube..."
if ! minikube status >/dev/null 2>&1; then
  minikube start
fi
minikube update-context >/dev/null

echo "==> [2/5] Construindo as imagens com o Docker (stage build do pipeline)..."
docker build -t app-projeto2:1.0 ./app
docker build -t mysql-projeto2:1.0 ./mysql

echo "==> [3/5] Enviando as imagens para dentro do Minikube..."
minikube image load app-projeto2:1.0
minikube image load mysql-projeto2:1.0

echo "==> [4/5] Aplicando os manifestos no cluster (stage deploy do pipeline)..."
kubectl apply -f secrets.yml
kubectl apply -f mysql-deployment.yml
kubectl apply -f app-deployment.yml
kubectl apply -f load-balancer.yml

echo "==> [5/5] Aguardando os pods ficarem prontos..."
kubectl rollout status deployment/mysql --timeout=180s
kubectl rollout status deployment/app --timeout=180s

kubectl get pods,svc

echo
echo "Deploy concluido! Para abrir a aplicacao no navegador, rode:"
echo "    minikube service app"