# Azure Verified Module for CI/CD Agents and Runners

This module deploys self-hosted Azure DevOps Agents and Github Runners with support for both Personal Access Token (PAT) and User Assigned Managed Identity (UAMI) authentication.

## Features

- Deploys Azure DevOps Agents with PAT or UAMI authentication
- Deploys Github Runners with PAT or GitHub App authentication
- Supports Azure Container Apps with KEDA auto scaling
- Supports Azure Container Instances
- Supports public or private networking
- Creates all required Azure resources or use existing ones
- No PAT token management required with UAMI authentication

## Authentication Methods

**Azure DevOps**: PAT (token-based) or UAMI (identity-based, no tokens required)
**GitHub**: PAT (token-based) or GitHub App (app-based)

## Prerequisites for UAMI Authentication

**Important**: Before using UAMI authentication with Azure DevOps, the User Assigned Managed Identity must be configured in your Azure DevOps organization:

1. **Add the identity to Azure DevOps**: The UAMI must be added as a service principal in your Azure DevOps organization with appropriate license (Basic or higher)
2. **Grant agent pool permissions**: The UAMI service principal needs Administrator role on the target agent pool
3. **Organization access**: The UAMI must be member of the Azure DevOps organization

### Setup Options

- **Option 1**: Use existing pre-configured UAMI (recommended) - requires `user_assigned_managed_identity_creation_enabled = false` and UAMI details
- **Option 2**: Let module create UAMI, then configure it manually in Azure DevOps afterward
- **Option 3**: Use `azure_devops_container_app_uami` example for fully automated setup

> **Note**: This module handles Azure infrastructure provisioning only. Azure DevOps organization configuration is managed separately (either manually or through examples using the azuredevops provider).

## Example Usage

### Azure DevOps with UAMI Authentication

Deploy Azure DevOps Agents using User Assigned Managed Identity - no PAT tokens required.

#### Using Existing UAMI (Recommended)

```hcl
module "azure_devops_agents_uami" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-agents"
  location = "uksouth"

  version_control_system_type                  = "azuredevops"
  version_control_system_authentication_method = "uami"  # No PAT required
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"

  # Use existing UAMI (must be configured in Azure DevOps first)
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-uami"
  user_assigned_managed_identity_client_id        = "12345678-1234-1234-1234-123456789012"
  user_assigned_managed_identity_principal_id     = "87654321-4321-4321-4321-210987654321"

  virtual_network_address_space = "10.0.0.0/16"
}
```

#### Creating New UAMI (Requires Manual Azure DevOps Setup)

```hcl
module "azure_devops_agents_uami" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-agents"
  location = "uksouth"

  version_control_system_type                  = "azuredevops"
  version_control_system_authentication_method = "uami"  # No PAT required
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"

  # Module creates new UAMI (you must configure it in Azure DevOps after creation)
  user_assigned_managed_identity_creation_enabled = true
  user_assigned_managed_identity_name             = "uami-my-agents"

  virtual_network_address_space = "10.0.0.0/16"
}
```

### Azure DevOps with PAT Authentication

Deploy Azure DevOps Agents using Personal Access Token authentication.

```hcl
module "azure_devops_agents_pat" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-agents"
  location = "uksouth"

  version_control_system_type                  = "azuredevops"
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"

  virtual_network_address_space = "10.0.0.0/16"
}
```

### GitHub Runners with PAT Authentication

Deploy GitHub Runners using Personal Access Token authentication.

```hcl
module "github_runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix  = "my-runners"
  location = "uksouth"

  version_control_system_type                  = "github"
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_repository            = "my-repository"

  virtual_network_address_space = "10.0.0.0/16"
}
```
