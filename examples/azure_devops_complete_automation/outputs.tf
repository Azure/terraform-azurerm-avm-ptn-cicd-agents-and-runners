# ========================================
# Azure Infrastructure Outputs
# ========================================

# ========================================
# PHASE 1 OUTPUTS: Prerequisites
# ========================================

# ========================================
# AVM Module Outputs (Phase 2 - Infrastructure)
# ========================================

# ========================================
# PHASE 2 OUTPUTS: Infrastructure
# ========================================

# ========================================
# Getting Started Guide
# ========================================

output "azure_devops_agent_pool_id" {
  description = "The ID of the created Azure DevOps agent pool"
  value       = azuredevops_agent_pool.this.id
}

output "azure_devops_agent_pool_name" {
  description = "The name of the created Azure DevOps agent pool"
  value       = azuredevops_agent_pool.this.name
}

output "azure_devops_project_id" {
  description = "The ID of the created Azure DevOps project"
  value       = azuredevops_project.this.id
}

output "azure_devops_project_name" {
  description = "The name of the created Azure DevOps project"
  value       = azuredevops_project.this.name
}

output "azure_devops_project_url" {
  description = "The URL of the created Azure DevOps project"
  value       = "${local.azure_devops_organization_url}/${azuredevops_project.this.name}"
}

output "azure_devops_service_connection_name" {
  description = "The name of the created Azure DevOps service connection"
  value       = azuredevops_serviceendpoint_azurerm.this.service_endpoint_name
}

output "container_app_environment_id" {
  description = "The resource ID of the Container App Environment from the AVM module"
  value       = module.azure_devops_agents.resource_id
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment from the AVM module"
  value       = module.azure_devops_agents.name
}

output "container_registry_id" {
  description = "The resource ID of the Container Registry from the AVM module"
  value       = module.azure_devops_agents.container_registry_resource_id
}

output "container_registry_login_server" {
  description = "The login server URL of the Container Registry from the AVM module"
  value       = module.azure_devops_agents.container_registry_login_server
}

# Debugging outputs for tenant/subscription verification
output "debug_info" {
  description = "Debug information for troubleshooting Azure AD integration"
  value = {
    azure_tenant_id    = data.azurerm_client_config.this.tenant_id
    azure_subscription = data.azurerm_client_config.this.subscription_id
    uami_client_id     = module.uami.client_id
    uami_principal_id  = module.uami.principal_id
    azure_devops_org   = local.azure_devops_organization_url
  }
}

output "getting_started_guide" {
  description = "Phase 1 setup summary and next steps"
  value = {
    phase_1_completed = {
      status                       = "✅ PHASE 1 COMPLETE - Prerequisites Ready"
      azure_devops_project_url     = "${local.azure_devops_organization_url}/${azuredevops_project.this.name}"
      azure_devops_agent_pool_name = azuredevops_agent_pool.this.name
      uami_client_id               = module.uami.client_id
      service_connection_name      = azuredevops_serviceendpoint_azurerm.this.service_endpoint_name
      resource_group_name          = azurerm_resource_group.this.name
    }

    automated_uami_setup = {
      status                    = "✅ AUTOMATED - No Manual Steps Required!"
      service_principal_created = "UAMI service principal entitlement created"
      group_membership_added    = "Added to Project Collection Service Accounts group"
    }

    phase_2_ready = {
      status                = "🚀 PHASE 2 DEPLOYED - Container Apps Infrastructure Ready"
      container_environment = "Container App Environment created with KEDA scaling"
      container_registry    = "Azure Container Registry with UAMI authentication"
      virtual_network       = "Private virtual network for secure communication"
      agent_scaling         = "KEDA-based auto-scaling configured for agent pool"
    }

    verification_urls = {
      azure_devops_project = "${local.azure_devops_organization_url}/${azuredevops_project.this.name}"
      agent_pools          = "${local.azure_devops_organization_url}/_settings/agentpools"
      service_connections  = "${local.azure_devops_organization_url}/${azuredevops_project.this.name}/_settings/adminservices"
    }

    what_we_accomplished = [
      "✅ Phase 1: Created UAMI with proper Azure RBAC permissions",
      "✅ Phase 1: Created Azure DevOps project with agent pool and service connection",
      "✅ Phase 1: Automated UAMI service principal setup (no manual steps!)",
      "✅ Phase 1: Added UAMI to Project Collection Service Accounts group automatically",
      "✅ Phase 2: Deployed Container App Environment with KEDA scaling",
      "✅ Phase 2: Created Azure Container Registry with UAMI authentication",
      "✅ Phase 2: Configured private networking for secure communication",
      "✅ End-to-End: Fully automated CI/CD agent infrastructure with no PAT tokens!"
    ]
  }
}

output "resource_group_id" {
  description = "The ID of the resource group containing the infrastructure"
  value       = azurerm_resource_group.this.id
}

output "resource_group_location" {
  description = "The Azure region where the infrastructure is deployed"
  value       = azurerm_resource_group.this.location
}

output "resource_group_name" {
  description = "The name of the resource group containing the infrastructure"
  value       = azurerm_resource_group.this.name
}

output "user_assigned_managed_identity_client_id" {
  description = "The client ID of the created User Assigned Managed Identity"
  value       = module.uami.client_id
}

output "user_assigned_managed_identity_id" {
  description = "The resource ID of the created User Assigned Managed Identity"
  value       = module.uami.resource_id
}

output "user_assigned_managed_identity_name" {
  description = "The name of the created User Assigned Managed Identity"
  value       = module.uami.resource.name
}

output "user_assigned_managed_identity_principal_id" {
  description = "The principal ID of the created User Assigned Managed Identity"
  value       = module.uami.principal_id
}

output "virtual_network_id" {
  description = "The resource ID of the Virtual Network from the AVM module"
  value       = module.azure_devops_agents.virtual_network_resource_id
}

output "virtual_network_name" {
  description = "The name of the Virtual Network from the AVM module"
  value       = module.azure_devops_agents.virtual_network_name
}
