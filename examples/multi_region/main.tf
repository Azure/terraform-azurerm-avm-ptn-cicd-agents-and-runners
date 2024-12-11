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
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
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

locals {
  primary_polling_interval_prime_number   = 17
  secondary_polling_interval_prime_number = 31
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

  resource_id = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}

# This is the module call
module "azure_devops_agents_primary" {
  source                                       = "../.."
  postfix                                      = "${random_string.name.result}1"
  location                                     = local.selected_region_primary
  version_control_system_type                  = "azuredevops"
  version_control_system_personal_access_token = var.azure_devops_agents_personal_access_token
  version_control_system_organization          = local.azure_devops_organization_url
  version_control_system_pool_name             = azuredevops_agent_pool.this.name
  virtual_network_address_space                = "10.0.0.0/16"
  container_app_polling_interval_seconds       = local.primary_polling_interval_prime_number
  tags                                         = local.tags
  depends_on                                   = [azuredevops_pipeline_authorization.this]
}

module "azure_devops_agents_secondary" {
  source                                       = "../.."
  postfix                                      = "${random_string.name.result}2"
  location                                     = local.selected_region_secondary
  version_control_system_type                  = "azuredevops"
  version_control_system_personal_access_token = var.azure_devops_agents_personal_access_token
  version_control_system_organization          = local.azure_devops_organization_url
  version_control_system_pool_name             = azuredevops_agent_pool.this.name
  virtual_network_address_space                = "10.1.0.0/16"
  container_app_polling_interval_seconds       = local.secondary_polling_interval_prime_number
  tags                                         = local.tags
  depends_on                                   = [azuredevops_pipeline_authorization.this]
}

output "primary_region" {
  value = local.selected_region_primary
}

output "secondary_region" {
  value = local.selected_region_secondary
}

output "container_app_environment_primary_resource_id" {
  value = module.azure_devops_agents_primary.resource_id
}

output "container_app_environment_primary_name" {
  value = module.azure_devops_agents_primary.name
}

output "container_app_job_primary_resource_id" {
  value = module.azure_devops_agents_primary.job_resource_id
}

output "container_app_job_primary_name" {
  value = module.azure_devops_agents_primary.job_name
}

output "container_app_environment_secondary_resource_id" {
  value = module.azure_devops_agents_secondary.resource_id
}

output "container_app_environment_secondary_name" {
  value = module.azure_devops_agents_secondary.name
}

output "container_app_job_secondary_resource_id" {
  value = module.azure_devops_agents_secondary.job_resource_id
}

output "container_app_job_secondary_name" {
  value = module.azure_devops_agents_secondary.job_name
}

# Region helpers
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.1.0"
}

resource "random_integer" "region_index_primary" {
  max = length(local.regions_primary) - 1
  min = 0
}

resource "random_integer" "region_index_secondary" {
  max = length(local.regions_secondary) - 1
  min = 0
}

locals {
  excluded_regions = [
    "westeurope" # Capacity issues
  ]
  included_regions = [
    "northcentralusstage", "westus2", "southeastasia", "swedencentral", "canadacentral", "westeurope", "northeurope", "eastus", "eastus2", "eastasia", "australiaeast", "germanywestcentral", "japaneast", "uksouth", "westus", "centralus", "northcentralus", "southcentralus", "koreacentral", "brazilsouth", "westus3", "francecentral", "southafricanorth", "norwayeast", "switzerlandnorth", "uaenorth", "canadaeast", "westcentralus", "ukwest", "centralindia", "italynorth", "polandcentral", "southindia"
  ]
  regions_primary           = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  regions_secondary         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name) && region.name != local.selected_region_primary]
  selected_region_primary   = local.regions_primary[random_integer.region_index_primary.result]
  selected_region_secondary = local.regions_secondary[random_integer.region_index_secondary.result]
}
