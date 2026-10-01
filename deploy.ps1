# deploy.ps1 - substitui o pipeline GitLab CI (build + deploy) rodando localmente no Minikube
$ErrorActionPreference = "Stop"

function Check($msg) {
    if ($LASTEXITCODE -ne 0) { Write-Host "ERRO: $msg" -ForegroundColor Red; exit 1 }
}

Write-Host "==> [1/5] Verificando o Minikube..." -ForegroundColor Cyan
minikube status | Out-Null
if ($LASTEXITCODE -ne 0) {
    minikube start
    Check "nao foi possivel iniciar o Minikube"
}
minikube update-context | Out-Null

Write-Host "==> [2/5] Construindo as imagens com o Docker (stage build do pipeline)..." -ForegroundColor Cyan
docker build -t app-projeto2:1.0 ./app
Check "falha no build da imagem da aplicacao"
docker build -t mysql-projeto2:1.0 ./mysql
Check "falha no build da imagem do MySQL"

Write-Host "==> [3/5] Enviando as imagens para dentro do Minikube..." -ForegroundColor Cyan
minikube image load app-projeto2:1.0
Check "falha ao carregar a imagem da aplicacao no Minikube"
minikube image load mysql-projeto2:1.0
Check "falha ao carregar a imagem do MySQL no Minikube"

Write-Host "==> [4/5] Aplicando os manifestos no cluster (stage deploy do pipeline)..." -ForegroundColor Cyan
kubectl apply -f secrets.yml
kubectl apply -f mysql-deployment.yml
kubectl apply -f app-deployment.yml
kubectl apply -f load-balancer.yml
Check "falha ao aplicar os manifestos"

Write-Host "==> [5/5] Aguardando os pods ficarem prontos..." -ForegroundColor Cyan
kubectl rollout status deployment/mysql --timeout=180s
kubectl rollout status deployment/app --timeout=180s
Check "os pods nao ficaram prontos a tempo"

kubectl get pods,svc

Write-Host ""
Write-Host "Deploy concluido! Para abrir a aplicacao no navegador, rode:" -ForegroundColor Green
Write-Host "    minikube service app" -ForegroundColor Yellow
Write-Host "(deixe essa janela aberta enquanto estiver usando a aplicacao)"