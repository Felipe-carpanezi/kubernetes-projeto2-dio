# Pipeline de deploy com Docker e Kubernetes (versão em script)

Aplicação de exemplo (PHP + MySQL) com deploy em Kubernetes. O projeto original
usava GitLab CI e um cluster no GCP. Esta versão substitui o pipeline por scripts
(`deploy.ps1` e `deploy.sh`) que rodam tudo localmente com Docker Desktop e Minikube,
sem custo de nuvem.

Projeto base: https://gitlab.com/denilsonbonatti/kubernetes-projeto2-dio

## Arquitetura

- **app**: 3 réplicas (PHP 7.4 + Apache) com um formulário que grava mensagens
- **mysql**: 1 réplica com volume persistente (PVC) e credenciais em um Secret
- **Services**: `app` (LoadBalancer) e `mysql-connection` (headless)

Tabela `mensagens`: `id` (int), `nome` (varchar), `email` (varchar), `comentario` (varchar).

## Equivalência com o pipeline original

| Pipeline GitLab CI | Script |
|---|---|
| stage `build` (docker build + push) | `docker build` + `minikube image load` |
| stage `deploy_gcp` (ssh + kubectl) | `kubectl apply` no Minikube local |

O arquivo `gitlab-ci.yml` foi mantido apenas como referência.

## Adaptações em relação ao original

- Imagens construídas localmente (`app-projeto2:1.0` e `mysql-projeto2:1.0`), sem Docker Hub
- `storageClassName` trocado de `standard-rwo` (GKE) para `standard` (Minikube)
- Manifestos corrigidos: `metadata` e `apiVersion` ausentes, `mountPath` no volume, Secret com `stringData`
- Imagem do MySQL passa a ser a da pasta `mysql`, para o `sql.sql` rodar de fato
- `sql.sql` com as colunas `id`, `nome`, `email`, `comentario`
- `dockerfile` do app instala a extensão `mysqli`, usada pelo `conexao.php`
- Formulário com campo de email, requisição relativa (sem IP fixo) e `incluir.php` com prepared statements

## Pré-requisitos

Docker Desktop, Minikube e kubectl.

## Como executar

Windows (PowerShell):

```powershell
.\deploy.ps1
```

Linux/macOS/Git Bash:

```bash
chmod +x deploy.sh
./deploy.sh
```

Abrir a aplicação (deixe o terminal aberto):

```bash
minikube service app
```

Verificar os dados gravados:

```bash
kubectl exec deploy/mysql -- mysql -uroot -pSenha123 meubanco -e "SELECT * FROM mensagens;"
```

## Observação

As credenciais (`Senha123`) são apenas para fins didáticos. Em produção, use um
Secret real, não versionado no repositório.