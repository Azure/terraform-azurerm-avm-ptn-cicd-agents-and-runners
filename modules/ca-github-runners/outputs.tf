output "resource" {
  description = "The container app environment."
  value       = azurerm_container_app_environment.this_ca_environment
  sensitive   = true
}

output "resource_runner_job" {
  description = "The runner job."
  value       = azapi_resource.runner_job
}
