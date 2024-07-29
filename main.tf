resource "azurerm_resource_group" "this" {
  count = var.resource_group_creation_enabled ? 1 : 0

  location = var.location
  name     = coalesce(var.resource_group_name, "rg-${var.postfix}")
}

locals {
  keda_meta_data_github = {
    owner = var.version_control_system_organization
    repos = var.version_control_system_repository
    targetWorkflowQueueLength = var.target_queue_length
    runnerScope = var.version_control_system_scope
  }
  keda_meta_data_azure_devops = {
    poolName = var.version_control_system_pool_name
    targetPipelinesQueueLength = var.target_queue_length
  }
  keda_meta_data_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.keda_meta_data_azure_devops) : jsonencode(local.keda_meta_data_github)
  keda_meta_data = tomap(jsondecode(local.keda_meta_data_final))
}

locals {
  environment_variables_azure_devops = []
  environment_variables_github = []
  environment_variables_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.environment_variables_azure_devops) : jsonencode(local.environment_variables_github)
  environment_variables = concat(tolist(jsondecode(local.environment_variables_final)), tolist(var.environment_variables))
}

locals {
  sensitive_environment_variables_azure_devops = [
    {
      name  = "AZP_URL"
      value = var.version_control_system_organization
      keda_auth_name = "organizationURL"
    },
    {
      name  = "AZP_TOKEN"
      value = var.version_control_system_personal_access_token
      keda_auth_name = "personalAccessToken"
    }
  ]
  sensitive_environment_variables_github = [
    {
      name  = "GH_TOKEN"
      value = var.version_control_system_personal_access_token
      keda_auth_name = "personalAccessToken"
    }
  ]

  sensitive_environment_variables_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.sensitive_environment_variables_azure_devops) : jsonencode(local.sensitive_environment_variables_github)
  sensitive_environment_variables = concat(tolist(jsondecode(local.sensitive_environment_variables_final)), tolist(var.sensitive_environment_variables))
}

module "container_app_job" {
  source = "./modules/container-app-job"

  resource_group_id                  = local.resource_group_id
  location                           = var.location
  postfix                            = var.postfix
  keda_rule_type = var.version_control_system_type == local.version_control_system_azure_devops ? "azure-pipelines" : "github-runner"
  keda_meta_data = local.keda_meta_data

  environment_variables = local.environment_variables
  sensitive_environment_variables = local.sensitive_environment_variables

  container_app_environment_id = azurerm_container_app_environment.this.id

  registry_login_server = var.create_container_registry ? module.container_registry[0].login_server : var.custom_container_registry_login_server

  placeholder_agent_name             = var.placeholder_agent_name
  placeholder_container_name         = var.placeholder_container_name
  placeholder_replica_retry_limit    = var.placeholder_replica_retry_limit
  placeholder_replica_timeout        = var.placeholder_replica_timeout
  polling_interval_seconds           = var.polling_interval_seconds
  container_cpu                   = var.container_cpu
  container_memory                = var.container_memory
  replica_retry_limit         = var.replica_retry_limit
  replica_timeout             = var.replica_timeout
  container_image_name               = local.container_images["default"].image_names[0]
  container_name = var.container_name
  placeholder_job_name = var.container_app_placeholder_job_name
  job_name      = var.container_app_job_name
  min_execution_count                = var.min_execution_count
  max_execution_count                = var.max_execution_count
  tags                               = var.tags
  user_assigned_managed_identity_id   = local.user_assigned_managed_identity_id
}
