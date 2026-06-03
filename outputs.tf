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
  value       = local.user_assigned_managed_identity_principal_id
}

output "virtual_network_name" {
  description = "The virtual network name."
  value       = var.use_private_networking && var.virtual_network_creation_enabled ? module.virtual_network[0].name : var.virtual_network_name
}

output "virtual_network_resource_id" {
  description = "The virtual network resource id."
  value       = var.use_private_networking && var.virtual_network_creation_enabled ? module.virtual_network[0].resource_id : null
}

output "webhook_queue_name" {
  description = "Name of the Storage Queue used for webhook-driven scaling. `null` when `webhook_scaling_enabled` is `false`."
  value       = var.webhook_scaling_enabled ? module.webhook_storage[0].queues["runner_jobs"].name : null
}

output "webhook_storage_account_name" {
  description = "Name of the Storage Account hosting the webhook queue. `null` when `webhook_scaling_enabled` is `false`."
  value       = var.webhook_scaling_enabled ? module.webhook_storage[0].name : null
}

output "webhook_storage_account_resource_id" {
  description = "Resource ID of the Storage Account hosting the webhook queue. `null` when `webhook_scaling_enabled` is `false`."
  value       = var.webhook_scaling_enabled ? module.webhook_storage[0].resource_id : null
}

output "webhook_queue_url" {
  description = "Queue URL (without `/messages` suffix). Use with Azure Storage SDKs, e.g. `QueueClient.from_queue_url(...)`. `null` when `webhook_scaling_enabled` is `false`."
  value       = var.webhook_scaling_enabled ? "https://${module.webhook_storage[0].fqdn["queue"]}/${module.webhook_storage[0].queues["runner_jobs"].name}" : null
}

output "webhook_queue_messages_endpoint" {
  description = "REST endpoint for the Put Message operation (queue URL + `/messages`). Use this if calling the Storage REST API directly rather than via an SDK. `null` when `webhook_scaling_enabled` is `false`."
  value       = var.webhook_scaling_enabled ? "https://${module.webhook_storage[0].fqdn["queue"]}/${module.webhook_storage[0].queues["runner_jobs"].name}/messages" : null
}
