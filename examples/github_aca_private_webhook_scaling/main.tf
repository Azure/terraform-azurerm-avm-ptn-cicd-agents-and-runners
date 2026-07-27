locals {
  tags = {
    scenario = "github_aca_private_webhook_scaling"
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
      version = "~> 6.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}

  # Required when webhook_scaling_enabled = true: the webhook Storage Account
  # has shared_access_key_enabled = false, so the azurerm provider must use AAD
  # for data-plane queue operations. See WEBHOOKS.md § Caller prerequisites.
  storage_use_azuread = true
}

provider "github" {}

resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
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
  name                = random_string.name.result
  description         = random_string.name.result
  auto_init           = true
  visibility          = data.github_organization.alz.plan == local.free_plan ? "public" : "private"
  allow_update_branch = true
  allow_merge_commit  = false
  allow_rebase_merge  = false
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

data "azapi_client_config" "this" {}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = toset(["Microsoft.App"])

  action      = "providers/${each.value}/register"
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
    webhook_storage_private_endpoint = {
      name           = "subnet-webhook-storage-private-endpoint"
      address_prefix = "10.0.2.0/29"
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

resource "azapi_resource" "private_dns_zone_acr" {
  location               = "global"
  name                   = "privatelink.azurecr.io"
  parent_id              = azapi_resource.rg.id
  type                   = "Microsoft.Network/privateDnsZones@2024-06-01"
  response_export_values = ["id", "name"]
  retry = {
    error_message_regex = ["CannotDeleteResource"]
  }
}

resource "azapi_resource" "private_dns_zone_queue" {
  location               = "global"
  name                   = "privatelink.queue.core.windows.net"
  parent_id              = azapi_resource.rg.id
  type                   = "Microsoft.Network/privateDnsZones@2024-06-01"
  response_export_values = ["id", "name"]
  retry = {
    error_message_regex = ["CannotDeleteResource"]
  }
}

resource "azapi_resource" "private_dns_zone_link_acr" {
  location  = "global"
  name      = "vnetlink"
  parent_id = azapi_resource.private_dns_zone_acr.id
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

resource "azapi_resource" "private_dns_zone_link_queue" {
  location  = "global"
  name      = "vnetlink"
  parent_id = azapi_resource.private_dns_zone_queue.id
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

# Identity for the webhook receiver (an Azure Function in your hub or online
# landing zone). This example does not deploy the receiver itself; see
# WEBHOOKS.md for the receiver contract and a sample Python implementation.
resource "azapi_resource" "webhook_receiver_uami" {
  location               = local.selected_region
  name                   = "uami-webhook-receiver-${random_string.name.result}"
  parent_id              = azapi_resource.rg.id
  type                   = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  body                   = {}
  response_export_values = ["properties.principalId"]
  tags                   = local.tags
}

# The module call - webhook mode enabled.
module "github_runners" {
  source = "../.."

  location                            = local.selected_region
  postfix                             = random_string.name.result
  version_control_system_organization = var.github_organization_name
  version_control_system_type         = "github"
  compute_types                       = ["azure_container_app"]
  # BYO network (the recommended private corp-connected posture).
  container_app_subnet_id                              = module.virtual_network.subnets["container_app"].resource_id
  container_registry_dns_zone_id                       = azapi_resource.private_dns_zone_acr.id
  container_registry_private_dns_zone_creation_enabled = false
  container_registry_private_endpoint_subnet_id        = module.virtual_network.subnets["container_registry_private_endpoint"].resource_id
  parent_id                                            = azapi_resource.rg.id
  resource_group_creation_enabled                      = false
  runner_visibility                                    = "private"
  tags                                                 = local.tags
  # GitHub App auth (PAT also works; App is recommended for production).
  version_control_system_github_application_id              = var.github_application_id
  version_control_system_github_application_installation_id = var.github_application_installation_id
  version_control_system_github_application_key             = var.github_application_key
  version_control_system_repository                         = github_repository.this.name
  # New: explicit runner labels so the receiver (and any consumer workflows)
  # can target this pool unambiguously. Pair with runner_no_default_labels so
  # the runner doesn't also accept arbitrary "self-hosted, linux" jobs.
  version_control_system_runner_labels            = ["self-hosted", "linux", "demo-webhook"]
  version_control_system_runner_no_default_labels = true
  virtual_network_creation_enabled                = false
  virtual_network_id                              = module.virtual_network.resource_id
  webhook_receiver_principal_ids                  = [azapi_resource.webhook_receiver_uami.output.properties.principalId]
  # New: webhook-driven KEDA scaling. The module provisions a private Storage
  # Queue; the receiver_principal_ids list grants the webhook receiver UAMI
  # `Storage Queue Data Message Sender` so it can enqueue jobs.
  webhook_scaling_enabled                    = true
  webhook_storage_private_endpoint_subnet_id = module.virtual_network.subnets["webhook_storage_private_endpoint"].resource_id
  webhook_storage_queue_dns_zone_id          = azapi_resource.private_dns_zone_queue.id

  depends_on = [
    azapi_resource.private_dns_zone_link_acr,
    azapi_resource.private_dns_zone_link_queue,
  ]
}

# Region selection
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
    "westeurope"
  ]
  included_regions = [
    "northcentralusstage", "westus2", "southeastasia", "canadacentral", "westeurope", "northeurope", "eastus", "eastus2", "eastasia", "australiaeast", "germanywestcentral", "japaneast", "uksouth", "westus", "centralus", "northcentralus", "southcentralus", "koreacentral", "brazilsouth", "westus3", "francecentral", "southafricanorth", "norwayeast", "switzerlandnorth", "uaenorth", "canadaeast", "westcentralus", "ukwest", "centralindia", "italynorth", "polandcentral", "southindia"
  ]
  regions         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  selected_region = "canadacentral"
}
