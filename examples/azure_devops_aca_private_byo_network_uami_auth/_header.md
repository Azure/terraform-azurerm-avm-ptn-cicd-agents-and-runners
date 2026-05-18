# Azure DevOps with Container Apps, bring-your-own VNet and DNS zone, and UAMI authentication

This example deploys Azure DevOps Agents to Azure Container Apps using a pre-existing virtual network and a caller-managed private DNS zone, with User Assigned Managed Identity (UAMI) authentication. Use this pattern when DNS zones are managed centrally.

## Authentication

This example uses the [`azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) provider's default Azure CLI authentication. Set the organization URL via the `AZDO_ORG_SERVICE_URL` environment variable and sign in with the Azure CLI before running Terraform:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/<your-organization>"
az login
```

For other provider authentication methods (Personal Access Token, OIDC, Managed Identity, Service Principal, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs#authentication).
