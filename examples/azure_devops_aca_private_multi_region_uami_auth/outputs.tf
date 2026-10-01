output "container_app_environment_primary_name" {
  value = module.azure_devops_agents_primary.name
}

output "container_app_environment_primary_resource_id" {
  value = module.azure_devops_agents_primary.resource_id
}

output "container_app_environment_secondary_name" {
  value = module.azure_devops_agents_secondary.name
}

output "container_app_environment_secondary_resource_id" {
  value = module.azure_devops_agents_secondary.resource_id
}

output "container_app_job_primary_name" {
  value = module.azure_devops_agents_primary.job_name
}

output "container_app_job_primary_resource_id" {
  value = module.azure_devops_agents_primary.job_resource_id
}

output "container_app_job_secondary_name" {
  value = module.azure_devops_agents_secondary.job_name
}

output "container_app_job_secondary_resource_id" {
  value = module.azure_devops_agents_secondary.job_resource_id
}

output "primary_region" {
  value = local.selected_region_primary
}

output "secondary_region" {
  value = local.selected_region_secondary
}
