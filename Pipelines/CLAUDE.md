# Pipelines

Azure DevOps CI/CD pipeline definitions. Three identical pipelines differing only by branch trigger, variable group, and service connection.

## Pipeline Structure (all three)

1. Install .NET 8 SDK (version 8.0.105)
2. Docker login to Azure Container Registry (ACR)
3. `docker build` with args: `ENVNAME` (environment name) and `CONTAINERNAME` (from `AppServiceName`)
4. `docker push` to ACR with tag `latest`
5. `az webapp restart` with 3-retry logic

## Environments

| File | Branch Trigger | Variable Group | ACR Service Connection |
|------|---------------|----------------|----------------------|
| DEV.yaml | `DEV` | `DEVVars` | `ServConn-DockerRegistrySPN-DEVQA` |
| QA.yaml | `QA` | `QAVars` | `ServConn-DockerRegistrySPN-QA` |
| PROD.yaml | `main` | `PRODVars` | `ServConn-DockerRegistrySPN-Prod` |

## Variables (from Azure DevOps variable groups)

- `$(AppServiceName)` — Azure App Service and ACR repository name
- `$(EnvName)` — injected as `ASPNETCORE_ENVIRONMENT` into Docker image
- `$(DevOpsServiceName)` — Azure subscription service connection for webapp restart
- `$(RG)` — Azure resource group

No secrets are hardcoded in these files — all come from the variable groups.
