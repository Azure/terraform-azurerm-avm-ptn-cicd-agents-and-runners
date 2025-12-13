output "azure_devops_managed_pool" {
  description = "Details of the optional Azure DevOps Managed DevOps Pool (managed runners)."
  value = var.azure_devops_managed_pool_enabled ? {
    name        = module.azure_devops_managed_pool[0].name
    resource_id = module.azure_devops_managed_pool[0].resource_id
    subnet_id   = local.azure_devops_managed_pool_subnet_id
    dev_center  = azapi_resource.azure_devops_managed_pool_dev_center[0].id
    dev_project = azapi_resource.azure_devops_managed_pool_dev_center_project[0].id
  } : null
}

output "container_app_subnet_resource_id" {
  description = "The subnet id of the container app job."
  value       = local.container_app_subnet_id
}

output "container_instance_names" {
  description = "The names of the container instances."
  value       = local.deploy_container_instance ? { for key, value in module.container_instance : key => value.name } : null
}

output "container_instance_resource_ids" {
  description = "The resource ids of the container instances."
  value       = local.deploy_container_instance ? { for key, value in module.container_instance : key => value.resource_id } : null
}

output "container_registry_login_server" {
  description = "The container registry login server."
  value       = var.container_registry_creation_enabled ? module.container_registry[0].login_server : var.custom_container_registry_login_server
}

output "container_registry_name" {
  description = "The container registry name."
  value       = var.container_registry_creation_enabled ? module.container_registry[0].name : null
}

output "container_registry_resource_id" {
  description = "The container registry resource id."
  value       = var.container_registry_creation_enabled ? module.container_registry[0].resource_id : null
}

output "github_hosted_runners_network_settings" {
  description = "Details for optional GitHub hosted runners Azure private networking (GitHub.Network/networkSettings)."
  value = var.github_hosted_runners_network_enabled ? {
    name        = azapi_resource.github_hosted_runners_network_settings[0].name
    resource_id = azapi_resource.github_hosted_runners_network_settings[0].id
    subnet_id   = local.github_hosted_runners_subnet_id
    github_id   = azapi_resource.github_hosted_runners_network_settings[0].output.tags.GitHubId
  } : null
}

output "job_name" {
  description = "The name of the container app job."
  value       = local.deploy_container_app ? module.container_app_job[0].name : null
}

output "job_resource_id" {
  description = "The resource id of the container app job."
  value       = local.deploy_container_app ? module.container_app_job[0].resource_id : null
}

output "name" {
  description = "The name of the container app environment."
  value       = local.deploy_container_app ? local.container_app_environment_name : null
}

output "placeholder_job_name" {
  description = "The name of the placeholder contaienr app job."
  value       = local.deploy_container_app ? module.container_app_job[0].placeholder_job_name : null
}

output "placeholder_job_resource_id" {
  description = "The resource id of the placeholder container app job."
  value       = local.deploy_container_app ? module.container_app_job[0].placeholder_job_resource_id : null
}

output "private_dns_zone_subnet_resource_id" {
  description = "The private dns zone id of the container registry."
  value       = local.container_registry_private_endpoint_subnet_id
}

output "resource_id" {
  description = "The resource id of the container app environment."
  value       = local.deploy_container_app ? local.container_app_environment_id : null
}

output "user_assigned_managed_identity_client_id" {
  description = "The client id of the user assigned managed identity."
  value       = var.user_assigned_managed_identity_creation_enabled ? module.user_assigned_managed_identity[0].client_id : null
}

output "user_assigned_managed_identity_id" {
  description = "The resource id of the user assigned managed identity."
  value       = var.user_assigned_managed_identity_creation_enabled ? module.user_assigned_managed_identity[0].resource_id : var.user_assigned_managed_identity_id
}

output "user_assigned_managed_identity_principal_id" {
  description = "The principal id of the user assigned managed identity."
  value       = var.user_assigned_managed_identity_creation_enabled ? module.user_assigned_managed_identity[0].principal_id : var.user_assigned_managed_identity_principal_id
}

output "virtual_network_name" {
  description = "The virtual network name."
  value       = var.use_private_networking && var.virtual_network_creation_enabled ? module.virtual_network[0].name : var.virtual_network_name
}

output "virtual_network_resource_id" {
  description = "The virtual network resource id."
  value       = var.use_private_networking && var.virtual_network_creation_enabled ? module.virtual_network[0].resource_id : null
}
