locals {
  tags = {
    scenario = "container_app_uami_auth"
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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  azure_devops_organization_url = "https://dev.azure.com/${var.azure_devops_organization_name}"
}

# Azure DevOps provider - uses Azure CLI for local development
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
  version = "0.4.2"
}

data "azurerm_client_config" "this" {}

# ========================================
# PHASE 1: PREREQUISITES
# ========================================
# This section creates the UAMI and Azure DevOps resources

# Create UAMI for agent authentication
module "uami" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.3"

  location            = local.selected_region
  name                = "uami-devops-agents-${random_string.name.result}"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = true
  tags                = local.tags
}

# ========================================
# Azure Resources
# ========================================

# Create Resource Group for our infrastructure
resource "azurerm_resource_group" "this" {
  location = local.selected_region
  name     = "${module.naming.resource_group.name_unique}-${random_string.name.result}"
  tags     = local.tags
}

# Grant necessary Azure permissions to the UAMI
resource "azurerm_role_assignment" "uami_contributor" {
  principal_id         = module.uami.principal_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "uami_acr_push" {
  principal_id         = module.uami.principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  role_definition_name = "AcrPush"
}

# Azure DevOps Project
resource "azuredevops_project" "this" {
  name        = "cicd-agents-${random_string.name.result}"
  description = "CI/CD Container App Agents Project"

  features = {
    "artifacts"    = "enabled"
    "boards"       = "disabled"
    "pipelines"    = "enabled"
    "repositories" = "enabled"
    "testplans"    = "disabled"
  }
}

# Azure DevOps Agent Pool
resource "azuredevops_agent_pool" "this" {
  name           = "ContainerApps-UAMI-${random_string.name.result}"
  auto_provision = false
  auto_update    = true
}

# Agent Queue (connects pool to project)
resource "azuredevops_agent_queue" "this" {
  project_id    = azuredevops_project.this.id
  agent_pool_id = azuredevops_agent_pool.this.id
}

# Service Connection for Azure access
resource "azuredevops_serviceendpoint_azurerm" "this" {
  project_id                             = azuredevops_project.this.id
  service_endpoint_name                  = "Azure-UAMI-${random_string.name.result}"
  description                            = "Service connection using UAMI authentication"
  service_endpoint_authentication_scheme = "ManagedServiceIdentity"

  credentials {
    serviceprincipalid = module.uami.client_id
  }

  azurerm_spn_tenantid      = data.azurerm_client_config.this.tenant_id
  azurerm_subscription_id   = data.azurerm_client_config.this.subscription_id
  azurerm_subscription_name = "Primary Subscription"
}

# Basic repository and pipeline
resource "azuredevops_git_repository" "this" {
  project_id     = azuredevops_project.this.id
  name           = "cicd-agents-repo"
  default_branch = "refs/heads/main"

  initialization {
    init_type = "Clean"
  }
}

# Upload the pipeline YAML file to the repository with actual values
resource "azuredevops_git_repository_file" "pipeline" {
  repository_id = azuredevops_git_repository.this.id
  file          = "azure-pipelines.yml"
  content = templatefile("${path.module}/pipeline.yml", {
    agent_pool_name         = azuredevops_agent_pool.this.name
    service_connection_name = azuredevops_serviceendpoint_azurerm.this.service_endpoint_name
    resource_group_name     = azurerm_resource_group.this.name
  })
  branch              = "refs/heads/main"
  commit_message      = "Add KEDA auto-scaling test pipeline with UAMI authentication"
  overwrite_on_create = true

  depends_on = [azuredevops_git_repository.this]
}

# Create the Azure DevOps pipeline based on the uploaded YAML file
resource "azuredevops_build_definition" "this" {
  project_id = azuredevops_project.this.id
  name       = "KEDA Auto-Scaling Test Pipeline"
  path       = "\\"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = azuredevops_git_repository.this.default_branch
    yml_path    = "azure-pipelines.yml"
  }

  depends_on = [
    azuredevops_git_repository_file.pipeline,
    azuredevops_agent_queue.this
  ]
}

# Authorize the pipeline to use the agent queue
resource "azuredevops_pipeline_authorization" "this" {
  project_id  = azuredevops_project.this.id
  resource_id = azuredevops_agent_queue.this.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.this.id
}

# ========================================
# Azure DevOps Service Principal Setup
# ========================================
# Automated setup: Create service principal entitlement and add to required group

# Get the Project Collection Service Accounts group (organization-level)
data "azuredevops_group" "project_collection_service_accounts" {
  name = "Project Collection Service Accounts"
  # No project_id specified - searches at organization level
}

# Add a delay to ensure UAMI is fully propagated in Azure AD
resource "time_sleep" "uami_propagation" {
  create_duration = "30s" # Wait 30 seconds for UAMI to propagate

  depends_on = [module.uami]
}

# Create service principal entitlement for the UAMI
resource "azuredevops_service_principal_entitlement" "uami" {
  account_license_type = "express"                # Basic license required for service principals
  origin               = "aad"                    # Azure Active Directory
  origin_id            = module.uami.principal_id # Use principal_id (object ID) for managed identities

  depends_on = [
    time_sleep.uami_propagation
  ]
}

# Add UAMI service principal to Project Collection Service Accounts group
resource "azuredevops_group_membership" "uami_service_accounts" {
  group   = data.azuredevops_group.project_collection_service_accounts.descriptor
  members = [azuredevops_service_principal_entitlement.uami.descriptor]
  mode    = "add"

  depends_on = [
    azuredevops_service_principal_entitlement.uami,
    data.azuredevops_group.project_collection_service_accounts
  ]
}

# ========================================
# PHASE 2: INFRASTRUCTURE
# ========================================
# Simple AVM module call using the UAMI created above

module "azure_devops_agents" {
  source = "../.."

  # Basic Configuration
  location                                        = local.selected_region
  postfix                                         = random_string.name.result
  version_control_system_organization             = local.azure_devops_organization_url
  version_control_system_type                     = "azuredevops"
  compute_types                                   = ["azure_container_app"]
  container_app_max_execution_count               = 10
  container_app_min_execution_count               = 0
  container_app_polling_interval_seconds          = 30
  resource_group_creation_enabled                 = false
  resource_group_name                             = azurerm_resource_group.this.name
  tags                                            = local.tags
  use_private_networking                          = false
  user_assigned_managed_identity_client_id        = module.uami.client_id
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = module.uami.resource_id
  user_assigned_managed_identity_principal_id     = module.uami.principal_id
  version_control_system_authentication_method    = "uami"
  version_control_system_personal_access_token    = null # Clean: no PAT needed!
  version_control_system_pool_name                = azuredevops_agent_pool.this.name
  virtual_network_address_space                   = "10.0.0.0/16"

  depends_on = [
    azurerm_role_assignment.uami_contributor,
    azurerm_role_assignment.uami_acr_push,
    azuredevops_agent_queue.this,
    azuredevops_serviceendpoint_azurerm.this,
    azuredevops_group_membership.uami_service_accounts
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
    "northcentralusstage", "westus2", "southeastasia", "swedencentral", "canadacentral", "westeurope", "northeurope", "eastus", "eastus2", "eastasia", "australiaeast", "germanywestcentral", "japaneast", "uksouth", "westus", "centralus", "northcentralus", "southcentralus", "koreacentral", "brazilsouth", "westus3", "francecentral", "southafricanorth", "norwayeast", "switzerlandnorth", "uaenorth", "canadaeast", "westcentralus", "ukwest", "centralindia", "italynorth", "polandcentral", "southindia"
  ]
  regions         = [for region in module.regions.regions : region.name if !contains(local.excluded_regions, region.name) && contains(local.included_regions, region.name)]
  selected_region = var.location_override != null ? var.location_override : local.regions[random_integer.region_index.result]
}
