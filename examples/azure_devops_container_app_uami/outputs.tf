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

output "user_assigned_managed_identity_client_id" {
  value = module.uami.client_id
}

output "user_assigned_managed_identity_resource_id" {
  value = module.uami.resource_id
}
