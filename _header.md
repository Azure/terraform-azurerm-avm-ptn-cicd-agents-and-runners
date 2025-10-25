# Azure Verified Module for CI/CD Agents and Runners

This module deploys self-hosted Azure DevOps Agents and Github Runners with support for both Personal Access Token (PAT) and User Assigned Managed Identity (UAMI) authentication.

## Features

- Deploys and configures Azure DevOps Agents with PAT or UAMI authentication
- Deploys and configures Github Runners with PAT or GitHub App authentication
- Supports Azure Container Apps with auto scaling from zero
- Supports Azure Container Instances as an alternative or complementary compute option
- Supports Public or Private Networking
- Deploys all Azure resources required or optionally supply your own
- Zero secrets management with UAMI authentication for Azure DevOps

## Authentication Methods

### Azure DevOps
- **Personal Access Token (PAT)**: Traditional token-based authentication
- **User Assigned Managed Identity (UAMI)**: Secure identity-based authentication without tokens

### GitHub
- **Personal Access Token (PAT)**: Traditional token-based authentication  
- **GitHub App**: App-based authentication for enhanced security

## Example Usage

### Azure DevOps with UAMI Authentication (Recommended)

This example shows how to deploy Azure DevOps Agents using User Assigned Managed Identity - no PAT tokens required for agent authentication.

```hcl
module "azure_devops_agents_uami" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"
  
  postfix  = "my-agents"
  location = "uksouth"
  
  # Azure DevOps Configuration
  version_control_system_type                  = "azuredevops"
  version_control_system_authentication_method = "uami"  # No PAT required!
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"
  
  # Network Configuration
  virtual_network_address_space = "10.0.0.0/16"
}
```

### Azure DevOps with PAT Authentication (Legacy)

This example shows how to deploy Azure DevOps Agents using the traditional PAT method.

```hcl
module "azure_devops_agents_pat" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"
  
  postfix  = "my-agents"
  location = "uksouth"
  
  # Azure DevOps Configuration
  version_control_system_type                  = "azuredevops"
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "https://dev.azure.com/my-organization"
  version_control_system_pool_name             = "my-agent-pool"
  
  # Network Configuration
  virtual_network_address_space = "10.0.0.0/16"
}
```

### GitHub Runners with PAT Authentication

This example shows how to deploy GitHub Runners using PAT authentication.

```hcl
module "github_runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"
  
  postfix  = "my-runners"
  location = "uksouth"
  
  # GitHub Configuration
  version_control_system_type                  = "github"
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_repository            = "my-repository"
  
  # Network Configuration
  virtual_network_address_space = "10.0.0.0/16"
}
```
