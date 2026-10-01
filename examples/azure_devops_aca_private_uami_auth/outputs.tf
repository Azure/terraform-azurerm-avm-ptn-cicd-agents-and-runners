output "container_app_environment_name" {
  value = module.azure_devops_agents.name
}

output "container_app_environment_resource_id" {
  value = module.azure_devops_agents.resource_id
}

output "container_app_job_name" {
  value = module.azure_devops_agents.job_name
}

output "container_app_job_resource_id" {
  value = module.azure_devops_agents.job_resource_id
}
