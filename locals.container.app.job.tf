locals {
  keda_meta_data = tomap(jsondecode(local.keda_meta_data_final))
  keda_meta_data_azure_devops = {
    poolName                   = var.version_control_system_pool_name
    targetPipelinesQueueLength = var.version_control_system_agent_target_queue_length
  }
  keda_meta_data_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.keda_meta_data_azure_devops) : jsonencode(local.keda_meta_data_github)
  keda_meta_data_github = var.version_control_system_authentication_method == "pat" ? {
    owner                     = var.version_control_system_organization
    repos                     = var.version_control_system_repository
    targetWorkflowQueueLength = var.version_control_system_agent_target_queue_length
    runnerScope               = var.version_control_system_runner_scope
    } : {
    owner                     = var.version_control_system_organization
    repos                     = var.version_control_system_repository
    targetWorkflowQueueLength = var.version_control_system_agent_target_queue_length
    runnerScope               = var.version_control_system_runner_scope
    applicationID             = var.version_control_system_github_application_id
    installationID            = var.version_control_system_github_installation_id
  }
}

locals {
  environment_variables = concat(tolist(jsondecode(local.environment_variables_final)), tolist(var.container_app_environment_variables))
  environment_variables_azure_devops = [
    {
      name  = "AZP_POOL"
      value = var.version_control_system_pool_name
    },
    {
      name  = "AZP_AGENT_NAME_PREFIX"
      value = local.version_control_system_agent_name_prefix
    }
  ]
  environment_variables_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.environment_variables_azure_devops) : jsonencode(local.environment_variables_github)
  environment_variables_github = var.version_control_system_authentication_method == "pat" ? [
    {
      name  = "RUNNER_NAME_PREFIX"
      value = local.version_control_system_agent_name_prefix
    },
    {
      name  = "REPO_URL"
      value = local.github_repository_url
    },
    {
      name  = "RUNNER_SCOPE"
      value = var.version_control_system_runner_scope
    },
    {
      name  = "EPHEMERAL"
      value = "true"
    },
    {
      name  = "ORG_NAME"
      value = var.version_control_system_organization
    },
    {
      name  = "ENTERPRISE_NAME"
      value = var.version_control_system_enterprise
    },
    {
      name  = "RUNNER_GROUP"
      value = var.version_control_system_runner_group
    }
    ] : [
    {
      name  = "RUNNER_NAME_PREFIX"
      value = local.version_control_system_agent_name_prefix
    },
    {
      name  = "REPO_URL"
      value = local.github_repository_url
    },
    {
      name  = "RUNNER_SCOPE"
      value = var.version_control_system_runner_scope
    },
    {
      name  = "EPHEMERAL"
      value = "true"
    },
    {
      name  = "ORG_NAME"
      value = var.version_control_system_organization
    },
    {
      name  = "ENTERPRISE_NAME"
      value = var.version_control_system_enterprise
    },
    {
      name  = "RUNNER_GROUP"
      value = var.version_control_system_runner_group
    },
    {
      name  = "APP_ID"
      value = var.version_control_system_github_application_id
    }
  ]
}

locals {
  environment_variables_placeholder = tolist(jsondecode(local.environment_variables_placeholder_final))
  environment_variables_placeholder_azure_devops = [
    {
      name  = "AZP_AGENT_NAME"
      value = local.version_control_system_placeholder_agent_name
    },
    {
      name  = "AZP_PLACEHOLDER"
      value = "true"
    }
  ]
  environment_variables_placeholder_final  = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.environment_variables_placeholder_azure_devops) : jsonencode(local.environment_variables_placeholder_github)
  environment_variables_placeholder_github = []
}

locals {
  sensitive_environment_variables = concat(tolist(jsondecode(local.sensitive_environment_variables_final)), tolist(var.container_app_sensitive_environment_variables))
  sensitive_environment_variables_azure_devops = [
    {
      name                      = "AZP_URL"
      value                     = var.version_control_system_organization
      container_app_secret_name = "organization-url"
      keda_auth_name            = "organizationURL"
    },
    {
      name                      = "AZP_TOKEN"
      value                     = var.version_control_system_personal_access_token
      container_app_secret_name = "personal-access-token"
      keda_auth_name            = "personalAccessToken"
    }
  ]
  sensitive_environment_variables_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.sensitive_environment_variables_azure_devops) : jsonencode(local.sensitive_environment_variables_github)
  sensitive_environment_variables_github = var.version_control_system_authentication_method == "pat" ? [
    {
      name                      = "ACCESS_TOKEN"
      value                     = var.version_control_system_personal_access_token
      container_app_secret_name = "personal-access-token"
      keda_auth_name            = "personalAccessToken"
    }
    ] : [
    {
      name                      = "APP_PRIVATE_KEY"
      value                     = var.version_control_system_github_application_key
      container_app_secret_name = "application-key"
      keda_auth_name            = "appKey"
    }
  ]
}
