resource "time_offset" "placeholder_job" {
  count = local.deploy_container_app ? 1 : 0

  offset_minutes = var.container_app_placeholder_schedule_offset_minutes
  triggers = {
    container_image                   = local.container_images["container_app"].image_names[0]
    offset_minutes                    = var.container_app_placeholder_schedule_offset_minutes
    environment_variables             = jsonencode(local.environment_variables)
    sensitive_environment_variables   = jsonencode(local.sensitive_environment_variables)
    environment_variables_placeholder = jsonencode(local.environment_variables_placeholder)
    image_version                     = var.default_image_repository_commit
  }

  depends_on = [module.container_registry, azurerm_container_app_environment.this]
}



module "container_app_job" {
  count  = local.deploy_container_app ? 1 : 0
  source = "./modules/container-app-job"

  resource_group_id = local.resource_group_id
  location          = var.location
  postfix           = var.postfix
  keda_rule_type    = var.version_control_system_type == local.version_control_system_azure_devops ? "azure-pipelines" : "github-runner"
  keda_meta_data    = local.keda_meta_data

  environment_variables             = local.environment_variables
  environment_variables_placeholder = local.environment_variables_placeholder
  sensitive_environment_variables   = local.sensitive_environment_variables

  container_app_environment_id = local.container_app_environment_id

  registry_login_server = local.registry_login_server
  container_image_name  = local.container_images["container_app"].image_names[0]

  job_name            = var.container_app_job_name
  job_container_name  = var.container_app_job_container_name
  replica_retry_limit = var.container_app_replica_retry_limit
  replica_timeout     = var.container_app_replica_timeout

  create_placeholder_job          = var.version_control_system_type == local.version_control_system_azure_devops
  placeholder_job_name            = var.container_app_placeholder_job_name
  placeholder_container_name      = var.container_app_placeholder_container_name
  placeholder_replica_retry_limit = var.container_app_placeholder_replica_retry_limit
  placeholder_replica_timeout     = var.container_app_placeholder_replica_timeout
  placeholder_cron_expression     = local.cron_expression

  polling_interval_seconds = var.container_app_polling_interval_seconds
  container_cpu            = var.container_app_container_cpu
  container_memory         = var.container_app_container_memory

  min_execution_count               = var.container_app_min_execution_count
  max_execution_count               = var.container_app_max_execution_count
  tags                              = var.tags
  user_assigned_managed_identity_id = local.user_assigned_managed_identity_id

  depends_on = [module.container_registry, azurerm_private_dns_zone_virtual_network_link.container_registry]
}