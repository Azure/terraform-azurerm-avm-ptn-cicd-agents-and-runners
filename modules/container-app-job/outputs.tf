output "name" {
  description = "The name of the container app job."
  value       = azapi_resource.job.name
}

output "placeholder_job_name" {
  description = "The name of the placeholder job."
  value       = var.create_placeholder_job ? azapi_resource.placeholder[0].name : null
}

output "placeholder_job_resource" {
  description = "The placeholder job resource."
  value       = var.create_placeholder_job ? azapi_resource.placeholder[0] : null
}

output "placeholder_job_resource_id" {
  description = "The resource id of the placeholder job."
  value       = var.create_placeholder_job ? azapi_resource.placeholder[0].id : null
}

output "resource_id" {
  description = "The resource id of the container app job."
  value       = azapi_resource.job.id
}

output "runner_job_resource" {
  description = "The job resource."
  value       = azapi_resource.job
}
