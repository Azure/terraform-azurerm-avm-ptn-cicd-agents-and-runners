output "resource_id" {
  value = local.deploy_container_app ? local.container_app_environment_id : null
  description = "The resource id of the container app environment."
}

output "name" {
  value = local.deploy_container_app ? local.container_app_environment_name : null
  description = "The name of the container app environment."
}

output "job_resource_id" {
  value = local.deploy_container_app ? module.container_app_job[0].resource_id : null
  description = "The resource id of the container app job."
}

output "job_name" {
  value = local.deploy_container_app ? module.container_app_job[0].name : null
  description = "The name of the container app job."
}

output "placeholder_job_resource_id" {
  value = local.deploy_container_app ? module.container_app_job[0].placeholder_job_resource_id : null
  description = "The resource id of the placeholder job."
}

output "placeholder_job_name" {
  value = local.deploy_container_app ? module.container_app_job[0].placeholder_job_name : null
  description = "The name of the placeholder job."
}

output "virtual_network_resource_id" {
  value = var.use_private_networking && var.create_virtual_network ? module.virtual_network[0].resource_id : null
  description = "The virtual network id of the container app job."
}

output "virtual_network_name" {
  value = var.use_private_networking && var.create_virtual_network ? module.virtual_network[0].name : var.virtual_network_name
}

output "container_app_subnet_resource_id" {
  value = local.container_app_subnet_id
  description = "The subnet id of the container app job."
}

output "private_dns_zone_subnet_resource_id" {
  value = local.container_registry_private_endpoint_subnet_id
  description = "The private dns zone id of the container app job."
}

output "container_registry_resource_id" {
  value = var.create_container_registry ? module.container_registry[0].resource_id : null
  description = "The container registry resource id."
}

output "container_registry_name" {
  value = var.create_container_registry ? module.container_registry[0].name : null
  description = "The container registry name."
}

output "container_registry_login_server" {
  value = var.create_container_registry ? module.container_registry[0].login_server : var.custom_container_registry_login_server
  description = "The container registry login server."
}

output "user_assigned_managed_identity_id" {
  value = var.create_user_assigned_managed_identity ? module.user_assigned_managed_identity[0].resource_id : var.user_assigned_managed_identity_id
  description = "The resource id of the user assigned managed identity."
}

output "user_assigned_managed_identity_principal_id" {
  value = var.create_user_assigned_managed_identity ? module.user_assigned_managed_identity[0].principal_id : var.user_assigned_managed_identity_principal_id
  description = "The principal id of the user assigned managed identity." 
}

output "container_instance_resource_ids" {
  value = local.deploy_container_instance ? { for key, value in module.container_instance : key => value.resource_id } : null
  description = "The resource ids of the container instances."
}

output "container_instance_names" {
  value = local.deploy_container_instance ? { for key, value in module.container_instance : key => value.name } : null
  description = "The names of the container instances."
}
