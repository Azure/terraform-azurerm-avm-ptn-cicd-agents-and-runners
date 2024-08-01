variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "github_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to GitHub."
  sensitive   = true
}

variable "github_runners_personal_access_token" {
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire)."
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
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
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
  enterprise_plan = "enterprise"
  free_plan       = "free"
  default_commit_email = "demo@microsoft.com"
  action_file = "action.yml"
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

# This is the module call
module "github_runners" {
  source                                       = "../.."
  postfix                                      = random_string.name.result
  location                                     = local.selected_region
  version_control_system_type                  = "github"
  version_control_system_personal_access_token = var.github_runners_personal_access_token
  version_control_system_organization          = var.github_organization_name
  version_control_system_repository            = github_repository.this.name
  virtual_network_address_space                = "10.0.0.0/16"
}

# Region helpers
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

locals {
  regions = [ for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name) ]
  included_regions = [
    "eastus",
    "westeurope",
    "southeastasia",
    "australiasoutheast",
    "westcentralus",
    "japaneast",
    "uksouth",
    "centralindia",
    "canadacentral",
    "westus2",
    "australiacentral",
    "australiaeast",
    "francecentral",
    "koreacentral",
    "northeurope",
    "centralus",
    "eastasia",
    "eastus2",
    "southcentralus",
    "northcentralus",
    "westus",
    "ukwest",
    "southafricanorth",
    "brazilsouth",
    "switzerlandnorth",
    "switzerlandwest",
    "germanywestcentral",
    "australiacentral2",
    "uaecentral",
    "uaenorth",
    "japanwest",
    "brazilsoutheast",
    "norwayeast",
    "norwaywest",
    "francesouth",
    "southindia",
    "koreasouth",
    "jioindiacentral",
    "jioindiawest",
    "qatarcentral",
    "canadaeast",
    "westus3",
    "swedencentral",
    "southafricawest",
    "germanynorth",
    "polandcentral",
    "israelcentral",
    "italynorth",
    "spaincentral"
  ]
  excluded_regions = [
    "westeurope"  # Capacity issues
  ]
  selected_region = local.regions[random_integer.region_index.result].name
}
