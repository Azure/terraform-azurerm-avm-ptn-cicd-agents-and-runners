output "resource" {
  description = "The container app environment."
  sensitive   = true # todo: check if we still need this
  value       = try(module.ca_ado[0].resource, module.ca_github[0].resource)
}

output "resource_placeholder_job" {
  description = "The placeholder job."
  value       = try(module.ca_ado[0].resource_placeholder_job, null)
}

output "resource_runner_job" {
  description = "The runner job."
  value       = try(module.ca_ado[0].resource_runner_job, module.ca_github[0].resource_runner_job)
}
