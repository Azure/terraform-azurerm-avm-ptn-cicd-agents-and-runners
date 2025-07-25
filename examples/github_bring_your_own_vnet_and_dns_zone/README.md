<!-- BEGIN_TF_DOCS -->
# GitHub example with private networking and bring your own virtual network  and DNS zone

This example deploys GitHub Runners to Azure Container Apps and Azure Container Instance using private networking and bring your own virtual network and DNS zone.

```hcl
locals {
  tags = {
    scenario = "default"
  }
}

terraform {
  required_version = ">= 1.9"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.36"
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

provider "github" {
  token = var.github_personal_access_token
  owner = var.github_organization_name
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
data "github_organization" "alz" {
  name = var.github_organization_name
}

locals {
  action_file          = "action.yml"
  default_commit_email = "demo@microsoft.com"
  free_plan            = "free"
}

resource "github_repository" "this" {
  name                 = random_string.name.result
  description          = random_string.name.result
  auto_init            = true
  visibility           = data.github_organization.alz.plan == local.free_plan ? "public" : "private"
  allow_update_branch  = true
  allow_merge_commit   = false
  allow_rebase_merge   = false
  vulnerability_alerts = true
}

resource "github_repository_file" "this" {
  repository          = github_repository.this.name
  file                = ".github/workflows/${local.action_file}"
  content             = file("${path.module}/${local.action_file}")
  commit_author       = local.default_commit_email
  commit_email        = local.default_commit_email
  commit_message      = "Add ${local.action_file} [skip ci]"
  overwrite_on_create = true
}

locals {
  resource_providers_to_register = {
    dev_center = {
      resource_provider = "Microsoft.App"
    }
  }
}

data "azurerm_client_config" "this" {}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
  resource_id = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
}

locals {
  subnets = {
    container_registry_private_endpoint = {
      name           = "subnet-container-registry-private-endpoint"
      address_prefix = "10.0.0.0/29"
    }
    container_app = {
      name           = "subnet-container-app"
      address_prefix = "10.0.1.0/27"
      delegation = [
        {
          name = "Microsoft.App/environments"
          service_delegation = {
            name = "Microsoft.App/environments"
          }
        }
      ]
    }
    container_instance = {
      name           = "subnet-container-instance"
      address_prefix = "10.0.2.0/28"
      delegation = [
        {
          name = "Microsoft.ContainerInstance/containerGroups"
          service_delegation = {
            name = "Microsoft.ContainerInstance/containerGroups"
          }
        }
      ]
    }
  }
  virtual_network_address_space = "10.0.0.0/16"
}

resource "azurerm_resource_group" "this" {
  location = local.selected_region
  name     = "rg-${random_string.name.result}"
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.7.1"

  address_space       = [local.virtual_network_address_space]
  location            = local.selected_region
  resource_group_name = azurerm_resource_group.this.name
  name                = "vnet-${random_string.name.result}"
  subnets             = local.subnets
}

resource "azurerm_private_dns_zone" "container_registry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry" {
  name                  = "privatelink.azurecr.io"
  private_dns_zone_name = azurerm_private_dns_zone.container_registry.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = module.virtual_network.resource_id
  tags                  = local.tags
}

# This is the module call
module "azure_devops_agents" {
  source = "../.."

  location                                             = local.selected_region
  postfix                                              = random_string.name.result
  version_control_system_organization                  = var.github_organization_name
  version_control_system_type                          = "github"
  compute_types                                        = ["azure_container_app", "azure_container_instance"]
  container_app_subnet_id                              = module.virtual_network.subnets["container_app"].resource_id
  container_instance_subnet_id                         = module.virtual_network.subnets["container_instance"].resource_id
  container_registry_dns_zone_id                       = azurerm_private_dns_zone.container_registry.id
  container_registry_private_dns_zone_creation_enabled = false
  container_registry_private_endpoint_subnet_id        = module.virtual_network.subnets["container_registry_private_endpoint"].resource_id
  resource_group_creation_enabled                      = false
  resource_group_name                                  = azurerm_resource_group.this.name
  tags                                                 = local.tags
  version_control_system_personal_access_token         = var.github_runners_personal_access_token
  version_control_system_repository                    = github_repository.this.name
  virtual_network_creation_enabled                     = false
  virtual_network_id                                   = module.virtual_network.resource_id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.container_registry]
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
    "northcentralusstage", "westus2", "southeastasia", "canadacentral", "westeurope", "northeurope", "eastus", "eastus2", "eastasia", "australiaeast", "germanywestcentral", "japaneast", "uksouth", "westus", "centralus", "northcentralus", "southcentralus", "koreacentral", "brazilsouth", "westus3", "francecentral", "southafricanorth", "norwayeast", "switzerlandnorth", "uaenorth", "canadaeast", "westcentralus", "ukwest", "centralindia", "italynorth", "polandcentral", "southindia"
  ]
  regions         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  selected_region = "canadacentral"
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.20)

- <a name="requirement_github"></a> [github](#requirement\_github) (~> 5.36)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource_action.resource_provider_registration](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource_action) (resource)
- [azurerm_private_dns_zone.container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) (resource)
- [github_repository_file.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [github_organization.alz](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/organization) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_github_organization_name"></a> [github\_organization\_name](#input\_github\_organization\_name)

Description: GitHub Organisation Name

Type: `string`

### <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token)

Description: The personal access token used for authentication to GitHub.

Type: `string`

### <a name="input_github_runners_personal_access_token"></a> [github\_runners\_personal\_access\_token](#input\_github\_runners\_personal\_access\_token)

Description: Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire).

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_container_app_environment_name"></a> [container\_app\_environment\_name](#output\_container\_app\_environment\_name)

Description: n/a

### <a name="output_container_app_environment_resource_id"></a> [container\_app\_environment\_resource\_id](#output\_container\_app\_environment\_resource\_id)

Description: n/a

### <a name="output_container_app_job_name"></a> [container\_app\_job\_name](#output\_container\_app\_job\_name)

Description: n/a

### <a name="output_container_app_job_resource_id"></a> [container\_app\_job\_resource\_id](#output\_container\_app\_job\_resource\_id)

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

### <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.7.1

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->