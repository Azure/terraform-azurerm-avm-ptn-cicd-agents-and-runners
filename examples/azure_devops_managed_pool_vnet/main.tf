locals {
  tags = {
    scenario = "azure_devops_managed_pool_vnet"
  }
}

terraform {
  required_version = ">= 1.9"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
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

provider "azuread" {}

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

resource "azuredevops_project" "this" {
  name = random_string.name.result
}

# This is the module call
module "managed_pool" {
  source = "../.."

  location                                        = local.selected_region
  postfix                                         = random_string.name.result
  version_control_system_organization             = local.azure_devops_organization_url
  version_control_system_type                     = "azuredevops"
  azure_devops_managed_pool_enabled               = true
  azure_devops_managed_pool_project_names         = toset([azuredevops_project.this.name])
  azure_devops_managed_pool_subnet_address_prefix = "10.1.0.0/27"
  azure_devops_managed_pool_vnet_address_space    = "10.1.0.0/24"
  compute_types                                   = []
  tags                                            = local.tags
  version_control_system_authentication_method    = "uami"

  depends_on = [azuredevops_project.this]
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
