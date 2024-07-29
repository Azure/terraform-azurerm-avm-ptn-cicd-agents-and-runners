output "resource_placeholder_job" {
  description = "The placeholder job."
  value       = var.create_placeholder_job ? azapi_resource.placeholder : null
}

output "resource_runner_job" {
  description = "The runner job."
  value       = azapi_resource.job
}
