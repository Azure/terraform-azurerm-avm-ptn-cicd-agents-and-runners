locals {
  tags = {
    scenario = "github_hosted_runners_network_vnet"
  }
}

terraform {
  required_version = ">= 1.9"

  required_providers {
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

resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

# This is the module call
module "github_hosted_runners_network" {
  source = "../.."

  location                                     = local.selected_region
  postfix                                      = random_string.name.result
  version_control_system_organization          = var.github_organization_name
  version_control_system_type                  = "github"
  compute_types                                = []
  github_hosted_runners_business_id            = var.github_hosted_runners_business_id
  github_hosted_runners_network_enabled        = true
  github_hosted_runners_subnet_address_prefix  = "10.2.0.0/27"
  github_hosted_runners_vnet_address_space     = "10.2.0.0/24"
  tags                                         = local.tags
  version_control_system_authentication_method = "pat"
  version_control_system_personal_access_token = var.github_runners_personal_access_token
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
