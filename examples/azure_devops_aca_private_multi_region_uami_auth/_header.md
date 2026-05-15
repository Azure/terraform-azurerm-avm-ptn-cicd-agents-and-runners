# Azure DevOps with Container Apps, multi-region private networking and UAMI authentication

This example deploys Azure DevOps Agents to Azure Container Apps in two regions using private networking and User Assigned Managed Identity (UAMI) authentication. A single UAMI is shared between both regional deployments.

> **Note:** Multi-region deployments may produce duplicate agent scaling — there is no built-in mechanism to coordinate scaling between regions.

## Authentication

This example uses the [`azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) provider's default Azure CLI authentication. Set the organization URL via the `AZDO_ORG_SERVICE_URL` environment variable and sign in with the Azure CLI before running Terraform:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/<your-organization>"
az login
```

For other provider authentication methods (Personal Access Token, OIDC, Managed Identity, Service Principal, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs#authentication).
