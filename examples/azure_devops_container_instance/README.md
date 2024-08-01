<!-- BEGIN_TF_DOCS -->
# Azure DevOps minimal example

This example deploys Azure DevOps Agents to Azure Container Apps using the minimal set of required variables.

```hcl
variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used for agent authentication to Azure DevOps."
  sensitive   = true
}

variable "azure_devops_agents_personal_access_token" {
  description = "Personal access token for Azure DevOps self-hosted agents (the token requires the 'Agent Pools - Read & Manage' scope and should have the maximum expiry)."
  type        = string
  sensitive   = true
}

locals {
  tags = {
    scenario = "default"
  }
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  azure_devops_organization_url = "https://dev.azure.com/${var.azure_devops_organization_name}"
}

provider "azuredevops" {
  personal_access_token = var.azure_devops_personal_access_token
  org_service_url       = local.azure_devops_organization_url
}

module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

resource "azuredevops_project" "this" {
  name = random_string.name.result
}

resource "azuredevops_agent_pool" "this" {
  name           = random_string.name.result
  auto_provision = false
  auto_update    = true
}

resource "azuredevops_agent_queue" "alz" {
  project_id    = azuredevops_project.this.id
  agent_pool_id = azuredevops_agent_pool.this.id
}

# This is the module call
module "azure_devops_agents" {
  source                                       = "../.."
  postfix                                      = random_string.name.result
  location                                     = module.regions.regions[random_integer.region_index.result].name
  version_control_system_type                  = "azuredevops"
  version_control_system_personal_access_token = var.azure_devops_agents_personal_access_token
  version_control_system_organization          = local.azure_devops_organization_url
  version_control_system_pool_name             = azuredevops_agent_pool.this.name
  virtual_network_address_space                = "10.0.0.0/16"
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.113)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azuredevops_agent_pool.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/agent_pool) (resource)
- [azuredevops_agent_queue.alz](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/agent_queue) (resource)
- [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_azure_devops_agents_personal_access_token"></a> [azure\_devops\_agents\_personal\_access\_token](#input\_azure\_devops\_agents\_personal\_access\_token)

Description: Personal access token for Azure DevOps self-hosted agents (the token requires the 'Agent Pools - Read & Manage' scope and should have the maximum expiry).

Type: `string`

### <a name="input_azure_devops_organization_name"></a> [azure\_devops\_organization\_name](#input\_azure\_devops\_organization\_name)

Description: Azure DevOps Organisation Name

Type: `string`

### <a name="input_azure_devops_personal_access_token"></a> [azure\_devops\_personal\_access\_token](#input\_azure\_devops\_personal\_access\_token)

Description: The personal access token used for agent authentication to Azure DevOps.

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_azure_devops_agents"></a> [azure\_devops\_agents](#module\_azure\_devops\_agents)

Source: ../..

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: >= 0.3.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->