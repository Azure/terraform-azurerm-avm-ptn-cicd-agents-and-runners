# Azure DevOps minimal example with a container instance, private networking and PAT authentication

This example deploys Azure DevOps Agents to Azure Container Instance using the minimal set of required variables using private networking and Personal Access Token (PAT) authentication.

> **Note**: This example is provided for backwards compatibility testing. For production deployments, consider the UAMI (User Assigned Managed Identity) authentication method instead — see the `azure_devops_container_instance` example.

## Authentication

This example uses the [`azuredevops`](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs) provider's default Azure CLI authentication for managing Azure DevOps resources. Set the organization URL via the `AZDO_ORG_SERVICE_URL` environment variable and sign in with the Azure CLI before running Terraform:

```bash
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/<your-organization>"
az login
```

The separate `azure_devops_agents_personal_access_token` variable below is the PAT used by the *self-hosted agents themselves* to register with the Azure DevOps agent pool — it is distinct from the provider authentication.

For other provider authentication methods (Personal Access Token, OIDC, Managed Identity, Service Principal, etc.), see the [provider authentication documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs#authentication).
