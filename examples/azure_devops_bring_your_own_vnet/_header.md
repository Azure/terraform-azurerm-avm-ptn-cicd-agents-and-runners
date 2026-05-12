# Azure DevOps example with private networking and bring your own virtual network

This example deploys Azure DevOps Agents to Azure Container Apps and Azure Container Instance using private networking, bring your own virtual network and User Assigned Managed Identity (UAMI) authentication.

## Authentication

This example uses the [`azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) provider's default Azure CLI authentication. Set the organization URL via the `AZDO_ORG_SERVICE_URL` environment variable and sign in with the Azure CLI before running Terraform:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/<your-organization>"
az login
```

For other authentication methods (Personal Access Token, OIDC, Managed Identity, Service Principal, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs#authentication).
