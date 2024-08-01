locals {
  container_instances = {
    for instance in range(1, var.container_instance_count + 1) : instance => {
      name = "${local.container_instance_name_prefix}-${instance}"
      availability_zones = [instance % 3]
    }
  }
}

locals {
  container_instance_environment_variables = concat(tolist(jsondecode(local.container_instance_environment_variables_final)), tolist(var.container_instance_environment_variables))
  container_instance_environment_variables_azure_devops = [
    {
      name  = "AZP_URL"
      value = var.version_control_system_organization
    },
    {
      name  = "AZP_POOL"
      value = var.version_control_system_pool_name
    },
    {
      name  = "AZP_AGENT_NAME"
      value = "${local.version_control_system_agent_name_prefix}-%s"
    }
  ]
  container_instance_environment_variables_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.container_instance_environment_variables_azure_devops) : jsonencode(local.container_instance_environment_variables_github)
  container_instance_environment_variables_github = [
    {
      name  = "GH_RUNNER_NAME"
      value = "${local.version_control_system_agent_name_prefix}-%s"
    },
    {
      name  = "GH_RUNNER_URL"
      value = var.version_control_system_runner_scope == "repo" ?  local.github_repository_url : "https://github.com/${var.version_control_system_organization}"
    },
    {
      name  = "GH_RUNNER_GROUP"
      value = var.version_control_system_runner_group
    }
  ]
}

locals {
  container_instance_sensitive_environment_variables = concat(tolist(jsondecode(local.container_instance_sensitive_environment_variables_final)), tolist(var.container_instance_sensitive_environment_variables))
  container_instance_sensitive_environment_variables_azure_devops = [
    {
      name                      = "AZP_TOKEN"
      value                     = var.version_control_system_personal_access_token
    }
  ]
  container_instance_sensitive_environment_variables_final = var.version_control_system_type == local.version_control_system_azure_devops ? jsonencode(local.container_instance_sensitive_environment_variables_azure_devops) : jsonencode(local.container_instance_sensitive_environment_variables_github)
  container_instance_sensitive_environment_variables_github = [
    {
      name                      = "GH_RUNNER_TOKEN"
      value                     = var.version_control_system_personal_access_token
    }
  ]
}

locals {
  container_instance_environment_variables_map = { for env in local.container_instance_environment_variables : env.name => env.value if env.value != null && env.value != "" }
  container_instance_sensitive_environment_variables_map = { for env in local.container_instance_sensitive_environment_variables : env.name => env.value if env.value != null && env.value != "" }
}
