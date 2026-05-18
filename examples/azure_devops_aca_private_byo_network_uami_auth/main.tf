


locals {
  tags = {
    scenario = "azure_devops_aca_private_byo_network_uami_auth"
  }
}

terraform {
  required_version = ">= 1.9"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.15"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {}

data "azuredevops_client_config" "this" {}

locals {
  azure_devops_organization_url = data.azuredevops_client_config.this.organization_url
}

resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
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

locals {
  resource_providers_to_register = {
    dev_center = {
      resource_provider = "Microsoft.App"
    }
  }
}

data "azapi_client_config" "this" {}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
  resource_id = "/subscriptions/${data.azapi_client_config.this.subscription_id}"
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

resource "azapi_resource" "rg" {
  location               = local.selected_region
  name                   = "rg-${random_string.name.result}"
  parent_id              = "/subscriptions/${data.azapi_client_config.this.subscription_id}"
  type                   = "Microsoft.Resources/resourceGroups@2024-11-01"
  response_export_values = ["id", "name"]
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.7.1"

  address_space       = [local.virtual_network_address_space]
  location            = local.selected_region
  resource_group_name = azapi_resource.rg.name
  name                = "vnet-${random_string.name.result}"
  subnets             = local.subnets
}

resource "azapi_resource" "private_dns_zone_container_registry" {
  location               = "global"
  name                   = "privatelink.azurecr.io"
  parent_id              = azapi_resource.rg.id
  type                   = "Microsoft.Network/privateDnsZones@2024-06-01"
  response_export_values = ["id", "name"]
  # ARM is eventually consistent about nested virtualNetworkLinks; the parent delete
  # can return 409 CannotDeleteResource briefly after the child is gone.
  retry = {
    error_message_regex = ["CannotDeleteResource"]
  }
}

resource "azapi_resource" "private_dns_zone_virtual_network_link_container_registry" {
  location  = "global"
  name      = "privatelink.azurecr.io"
  parent_id = azapi_resource.private_dns_zone_container_registry.id
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01"
  body = {
    properties = {
      registrationEnabled = false
      virtualNetwork = {
        id = module.virtual_network.resource_id
      }
    }
  }
  response_export_values = ["id"]
  tags                   = local.tags
}

# User Assigned Managed Identity for agent authentication
module "uami" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.3"

  location            = local.selected_region
  name                = "uami-devops-agents-${random_string.name.result}"
  resource_group_name = azapi_resource.rg.name
  enable_telemetry    = true
  tags                = local.tags
}

# Add UAMI as a service principal in Azure DevOps and grant the Administrator
# role on the project's agent pool queue. Administrator on the queue is the
# least-privilege role required for the UAMI to register self-hosted agents
# into the pool. See the README "Required permissions" section for details.
resource "time_sleep" "uami_propagation" {
  create_duration = "30s"

  depends_on = [module.uami]
}

resource "azuredevops_service_principal_entitlement" "uami" {
  account_license_type = "express"
  origin               = "aad"
  origin_id            = module.uami.principal_id

  depends_on = [
    time_sleep.uami_propagation
  ]
}

# Grant the UAMI the Administrator role on the org-level agent pool. The
# lower-privilege Service Account role only permits an already-registered
# agent to create sessions and listen for jobs; it does not grant the Manage
# permission needed to register a new agent. This module's containers are
# ephemeral and call POST /_apis/distributedtask/pools/{poolId}/agents on
# every start, so Administrator is the lowest built-in role that works.
resource "azuredevops_securityrole_assignment" "uami_pool_admin" {
  scope       = "distributedtask.agentpoolrole"
  resource_id = azuredevops_agent_pool.this.id
  # Must be the AzDO Service Principal UUID (entitlement id), not the AAD object id;
  # the provider polls the role assignment until the returned Identity.ID matches identity_id.
  identity_id = azuredevops_service_principal_entitlement.uami.id
  role_name   = "Administrator"
}

# This is the module call
module "azure_devops_agents" {
  source = "../.."

  location                                             = local.selected_region
  postfix                                              = random_string.name.result
  version_control_system_organization                  = local.azure_devops_organization_url
  version_control_system_type                          = "azuredevops"
  compute_types                                        = ["azure_container_app", "azure_container_instance"]
  container_app_subnet_id                              = module.virtual_network.subnets["container_app"].resource_id
  container_instance_subnet_id                         = module.virtual_network.subnets["container_instance"].resource_id
  container_registry_dns_zone_id                       = azapi_resource.private_dns_zone_container_registry.id
  container_registry_private_dns_zone_creation_enabled = false
  container_registry_private_endpoint_subnet_id        = module.virtual_network.subnets["container_registry_private_endpoint"].resource_id
  parent_id                                            = azapi_resource.rg.id
  resource_group_creation_enabled                      = false
  tags                                                 = local.tags
  user_assigned_managed_identity_creation_enabled      = false
  user_assigned_managed_identity_id                    = module.uami.resource_id
  version_control_system_personal_access_token         = null
  version_control_system_pool_name                     = azuredevops_agent_pool.this.name
  virtual_network_creation_enabled                     = false
  virtual_network_id                                   = module.virtual_network.resource_id

  depends_on = [
    azuredevops_pipeline_authorization.this,
    azapi_resource.private_dns_zone_virtual_network_link_container_registry,
    azuredevops_securityrole_assignment.uami_pool_admin
  ]
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
  selected_region = local.regions[random_integer.region_index.result]
}
