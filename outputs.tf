output "resource" {
  description = "The container app environment."
  value       = try(module.ca_ado[0].resource, module.ca_github[0].resource)
  sensitive   = true
}

output "resource_placeholder_job" {
  description = "The placeholder job."
  value       = try(module.ca_ado[0].resource_placeholder_job, null)
}

output "resource_runner_job" {
  description = "The runner job."
  value       = try(module.ca_ado[0].resource_runner_job, module.ca_github[0].resource_runner_job)
}
