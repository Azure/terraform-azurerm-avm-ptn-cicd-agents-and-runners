# ========================================
# Azure DevOps CI/CD Agents - Complete Setup Example
# ========================================
# This example demonstrates a complete setup in two phases:
# 1. Prerequisites: Creates UAMI and Azure DevOps resources
# 2. Infrastructure: Deploys Container Apps using the UAMI
#
# Clean separation: DevOps setup separate from infrastructure deployment

locals {
  azure_devops_organization_url = var.azure_devops_organization_url
  tags = {
    scenario    = "complete_azdo_setup"
    environment = var.environment
    purpose     = "cicd-agents"
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

# Azure DevOps provider - uses Azure CLI for local development
provider "azuredevops" {
  org_service_url = local.azure_devops_organization_url
  use_cli         = true # Simple: uses your 'az login' context
}

# ========================================
# Random Resources for Naming
# ========================================

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

# ========================================
# Data Sources
# ========================================

data "azurerm_client_config" "this" {}

# ========================================
# PHASE 1: PREREQUISITES
# ========================================
# This section creates the UAMI and Azure DevOps resources

# Create UAMI for agent authentication
module "uami" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.3"

  location            = azurerm_resource_group.this.location
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
  location = var.location
  name     = "${module.naming.resource_group.name_unique}-${random_string.name.result}"
  tags     = local.tags
}

# Grant necessary Azure permissions to the UAMI
resource "azurerm_role_assignment" "uami_contributor" {
  principal_id         = module.uami.principal_id
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"

  depends_on = [module.uami]
}

resource "azurerm_role_assignment" "uami_acr_push" {
  principal_id         = module.uami.principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  role_definition_name = "AcrPush"

  depends_on = [module.uami]
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
  name           = "ContainerApps-${random_string.name.result}"
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
    module.uami,
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
  location                            = var.location
  postfix                             = random_string.name.result
  version_control_system_organization = local.azure_devops_organization_url
  # Version Control System Configuration - uses the resources created above
  version_control_system_type = "azuredevops"
  # Compute Configuration
  compute_types = var.compute_types
  # Container App Configuration
  container_app_max_execution_count      = 10
  container_app_min_execution_count      = 0
  container_app_polling_interval_seconds = 30
  default_image_repository_commit        = var.default_image_repository_commit
  # Use the Resource Group we created
  resource_group_creation_enabled          = false
  resource_group_name                      = azurerm_resource_group.this.name
  tags                                     = local.tags
  use_private_networking                   = var.use_private_networking
  user_assigned_managed_identity_client_id = module.uami.client_id
  # Use the UAMI created in Phase 1
  user_assigned_managed_identity_creation_enabled = false
  user_assigned_managed_identity_id               = module.uami.resource_id
  user_assigned_managed_identity_principal_id     = module.uami.principal_id
  version_control_system_authentication_method    = "uami"
  version_control_system_personal_access_token    = null # Clean: no PAT needed!
  version_control_system_pool_name                = azuredevops_agent_pool.this.name
  # Networking Configuration
  virtual_network_address_space = var.virtual_network_address_space

  # Clean dependencies - everything from Phase 1 including automated UAMI setup
  depends_on = [
    azurerm_role_assignment.uami_contributor,
    azurerm_role_assignment.uami_acr_push,
    azuredevops_agent_queue.this,
    azuredevops_serviceendpoint_azurerm.this,
    azuredevops_group_membership.uami_service_accounts
  ]
}
