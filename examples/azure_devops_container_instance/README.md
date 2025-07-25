<!-- BEGIN_TF_DOCS -->
# Azure DevOps minimal example with a container instance and private networking

This example deploys Azure DevOps Agents to Azure Container Instance using the minimal set of required variables using private networking.

```hcl
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
      version = "~> 4.20"
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

resource "azuredevops_agent_queue" "this" {
  project_id    = azuredevops_project.this.id
  agent_pool_id = azuredevops_agent_pool.this.id
}

locals {
  default_branch  = "refs/heads/main"
  pipeline_file   = "pipeline.yml"
  repository_name = "example-repo"
}

resource "azuredevops_git_repository" "this" {
  project_id     = azuredevops_project.this.id
  name           = local.repository_name
  default_branch = local.default_branch
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository_file" "this" {
  repository_id = azuredevops_git_repository.this.id
  file          = local.pipeline_file
  content = templatefile("${path.module}/${local.pipeline_file}", {
    agent_pool_name = azuredevops_agent_pool.this.name
  })
  branch              = local.default_branch
  commit_message      = "[skip ci]"
  overwrite_on_create = true
}

resource "azuredevops_build_definition" "this" {
  project_id = azuredevops_project.this.id
  name       = "Example Build Definition"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = azuredevops_git_repository.this.default_branch
    yml_path    = local.pipeline_file
  }
}

resource "azuredevops_pipeline_authorization" "this" {
  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_agent_queue.this.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.this.id
}

# This is the module call
module "azure_devops_agents" {
  source = "../.."

  location                                     = local.selected_region
  postfix                                      = random_string.name.result
  version_control_system_organization          = local.azure_devops_organization_url
  version_control_system_type                  = "azuredevops"
  compute_types                                = ["azure_container_instance"]
  tags                                         = local.tags
  version_control_system_personal_access_token = var.azure_devops_agents_personal_access_token
  version_control_system_pool_name             = azuredevops_agent_pool.this.name
  virtual_network_address_space                = "10.0.0.0/16"

  depends_on = [azuredevops_pipeline_authorization.this]
}

# Region helpers
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.3.0"
}

resource "random_integer" "region_index" {
  max = length(local.regions) - 1
  min = 0
}

locals {
  excluded_regions = [
    "westeurope" # Capacity issues
  ]
  included_regions = [
    "northcentralusstage", "westus2", "southeastasia", "swedencentral", "canadacentral", "westeurope", "northeurope", "eastus", "eastus2", "eastasia", "australiaeast", "germanywestcentral", "japaneast", "uksouth", "westus", "centralus", "northcentralus", "southcentralus", "koreacentral", "brazilsouth", "westus3", "francecentral", "southafricanorth", "norwayeast", "switzerlandnorth", "uaenorth", "canadaeast", "westcentralus", "ukwest", "centralindia", "italynorth", "polandcentral", "southindia"
  ]
  regions         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  selected_region = local.regions[random_integer.region_index.result]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.20)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azuredevops_agent_pool.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/agent_pool) (resource)
- [azuredevops_agent_queue.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/agent_queue) (resource)
- [azuredevops_build_definition.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) (resource)
- [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) (resource)
- [azuredevops_git_repository_file.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository_file) (resource)
- [azuredevops_pipeline_authorization.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) (resource)
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

The following outputs are exported:

### <a name="output_container_instance_names"></a> [container\_instance\_names](#output\_container\_instance\_names)

Description: n/a

### <a name="output_container_instance_resource_ids"></a> [container\_instance\_resource\_ids](#output\_container\_instance\_resource\_ids)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_azure_devops_agents"></a> [azure\_devops\_agents](#module\_azure\_devops\_agents)

Source: ../..

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: 0.3.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->