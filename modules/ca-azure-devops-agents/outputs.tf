output "resource" {
  description = "The container app environment."
  sensitive   = true
  value       = azurerm_container_app_environment.this_ca_environment
}

output "resource_placeholder_job" {
  description = "The placeholder job."
  value       = azapi_resource.placeholder_job
}

output "resource_runner_job" {
  description = "The runner job."
  value       = azapi_resource.runner_job
}
