# Azure DevOps example with private networking and multi-region

This example deploys Azure DevOps Agents to Azure Container Apps in two regions using private networking and User Assigned Managed Identity (UAMI) authentication. A single UAMI is shared between both regional deployments.

>NOTE: Multi-region support may result in duplicated agent scaling, there is no built-in mechanism to prevent this.

## Authentication

This example uses the [`azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) provider's default Azure CLI authentication. Set the organization URL via the `AZDO_ORG_SERVICE_URL` environment variable and sign in with the Azure CLI before running Terraform:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/<your-organization>"
az login
```

For other authentication methods (Personal Access Token, OIDC, Managed Identity, Service Principal, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs#authentication).
