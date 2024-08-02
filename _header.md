# Azure Verified Module for CI/CD Agents and Runners

This module deploys self-hosted Azure DevOps Agents and Github Runners.

## Features

- Deploys and configures Azure DevOps Agents
- Deploys and configures Github Runners
- Supports Azure Container Apps with auto scaling from zero
- Supports Azure Container Instances as an alternative or complementary compute option
- Supports Public or Private Networking
- Deploys all Azure resource required or optionally supply your own

## Example Usage

This example shows how to deploy Azure DevOps Agents to Azure Container Apps using the minimal set of required variables with private networking.

```hcl
module "azure_devops_agents" {
  source                                       = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version                                      = "~> 0.2"
  postfix                                      = "my-agents"
  location                                     = "uksouth"
  version_control_system_type                  = "azuredevops"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_pool_name             = "my-agent-pool"
  virtual_network_address_space                = "10.0.0.0/16"
}
```

This example shows how to deploy GitHub Runners to Azure Container Apps using the minimal set of required variables with private networking.

```hcl
module "github_runners" {
  source                                       = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version                                      = "~> 0.2"
  postfix                                      = "my-runners"
  location                                     = "uksouth"
  version_control_system_type                  = "github"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_repository            = "my-reository"
  virtual_network_address_space                = "10.0.0.0/16"
}
```
