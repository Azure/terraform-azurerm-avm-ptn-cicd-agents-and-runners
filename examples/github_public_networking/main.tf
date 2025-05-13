

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use for the deployment."
}

variable "github_application_key" {
  type        = string
  description = "The application key used for the GitHub App authentication method. Import key file as environment variable: $env:TF_VAR_github_application_key = Get-Content path\to\\[private_key_name].pem -Raw"
  sensitive   = true
}

variable "github_application_id" {
  type        = string
  description = "The application ID used for the GitHub App authentication method."
}

variable "github_installation_id" {
  type        = string
  description = "The Installation ID used for the GitHub App authentication method."
}

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
  subscription_id = var.subscription_id
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

# This is the module call
module "github_runners" {
  source                                        = "../.."
  postfix                                       = random_string.name.result
  location                                      = local.selected_region
  version_control_system_type                   = "github"
  version_control_system_authentication_method  = "github_app"
  version_control_system_github_application_key = var.github_application_key
  version_control_system_github_application_id  = var.github_application_id
  version_control_system_github_installation_id = var.github_installation_id
  version_control_system_organization           = var.github_organization_name
  version_control_system_repository             = github_repository.this.name
  use_private_networking                        = false
  tags                                          = local.tags
  depends_on                                    = [github_repository_file.this]
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
