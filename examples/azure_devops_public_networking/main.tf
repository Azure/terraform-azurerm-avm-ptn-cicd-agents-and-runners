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
  max = length(local.regions) - 1
  min = 0
}

locals {
  regions = [ for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) ]
  excluded_regions = [
    "westeurope"  # Capacity issues
  ]
  selected_region = local.regions[random_integer.region_index.result].name
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
  default_branch = "refs/heads/main"
  pipeline_file  = "pipeline.yml"
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
  repository_id       = azuredevops_git_repository.this.id
  file                = local.pipeline_file
  content             = templatefile("${path.module}/${local.pipeline_file}", {
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
  source                                       = "../.."
  postfix                                      = random_string.name.result
  location                                     = local.selected_region
  version_control_system_type                  = "azuredevops"
  version_control_system_personal_access_token = var.azure_devops_agents_personal_access_token
  version_control_system_organization          = local.azure_devops_organization_url
  version_control_system_pool_name             = azuredevops_agent_pool.this.name
  use_private_networking                       = false
}

output "container_app_environment_resource_id" {
  value = module.azure_devops_agents.resource_id
}

output "container_app_environment_name" {
  value = module.azure_devops_agents.name
}

output "container_app_job_resource_id" {
  value = module.azure_devops_agents.job_resource_id
}

output "container_app_job_name" {
  value = module.azure_devops_agents.job_name
}
