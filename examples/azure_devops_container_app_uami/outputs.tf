output "container_app_subnet_resource_id" {
  description = "The subnet id of the container app job."
  value       = module.azure_devops_agents.container_app_subnet_resource_id
}

output "container_registry_login_server" {
  description = "The container registry login server."
  value       = module.azure_devops_agents.container_registry_login_server
}

output "container_registry_name" {
  description = "The container registry name."
  value       = module.azure_devops_agents.container_registry_name
}

output "job_name" {
  description = "The name of the container app job."
  value       = module.azure_devops_agents.job_name
}

output "job_resource_id" {
  description = "The resource id of the container app job."
  value       = module.azure_devops_agents.job_resource_id
}

output "placeholder_job_name" {
  description = "The name of the placeholder container app job."
  value       = module.azure_devops_agents.placeholder_job_name
}

output "placeholder_job_resource_id" {
  description = "The resource id of the placeholder container app job."
  value       = module.azure_devops_agents.placeholder_job_resource_id
}

output "user_assigned_managed_identity_client_id" {
  description = "The client id of the user assigned managed identity."
  value       = module.azure_devops_agents.user_assigned_managed_identity_client_id
}

output "user_assigned_managed_identity_id" {
  description = "The resource id of the user assigned managed identity."
  value       = module.azure_devops_agents.user_assigned_managed_identity_id
}

output "virtual_network_name" {
  description = "The virtual network name."
  value       = module.azure_devops_agents.virtual_network_name
}
