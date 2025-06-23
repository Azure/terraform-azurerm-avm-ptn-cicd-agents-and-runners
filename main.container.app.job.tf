module "container_app_job" {
  source = "./modules/container-app-job"
  count  = local.deploy_container_app ? 1 : 0

  container_app_environment_id      = local.container_app_environment_id
  container_cpu                     = var.container_app_container_cpu
  container_image_name              = local.container_images["container_app"].image_names[0]
  container_memory                  = var.container_app_container_memory
  environment_variables             = local.environment_variables
  job_container_name                = var.container_app_job_container_name
  job_name                          = var.container_app_job_name
  keda_meta_data                    = local.keda_meta_data
  keda_rule_type                    = var.version_control_system_type == local.version_control_system_azure_devops ? "azure-pipelines" : "github-runner"
  location                          = var.location
  max_execution_count               = var.container_app_max_execution_count
  min_execution_count               = var.container_app_min_execution_count
  polling_interval_seconds          = var.container_app_polling_interval_seconds
  postfix                           = var.postfix
  registry_login_server             = local.registry_login_server
  replica_retry_limit               = var.container_app_replica_retry_limit
  replica_timeout                   = var.container_app_replica_timeout
  resource_group_id                 = local.resource_group_id
  sensitive_environment_variables   = local.sensitive_environment_variables
  user_assigned_managed_identity_id = local.user_assigned_managed_identity_id
  environment_variables_placeholder = local.environment_variables_placeholder
  placeholder_container_name        = var.container_app_placeholder_container_name
  placeholder_job_creation_enabled  = var.version_control_system_type == local.version_control_system_azure_devops
  placeholder_job_name              = var.container_app_placeholder_job_name
  placeholder_replica_retry_limit   = var.container_app_placeholder_replica_retry_limit
  placeholder_replica_timeout       = var.container_app_placeholder_replica_timeout
  registry_password                 = var.custom_container_registry_password
  registry_username                 = var.custom_container_registry_username
  tags                              = var.tags

  depends_on = [
    module.container_registry,
    azurerm_private_dns_zone_virtual_network_link.container_registry,
    time_sleep.delay_after_container_image_build,
    time_sleep.delay_after_container_app_environment_creation
  ]
}
