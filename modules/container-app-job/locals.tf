locals {
  job_name = var.job_name == null ? "caj-${var.postfix}" : var.job_name
  placeholder_job_name = var.placeholder_job_name == null ? "caj-${var.postfix}-ph" : var.placeholder_job_name
}

locals {
  environment_variables = [ for env in var.environment_variables : {
    name  = env.name
    value = env.value
  } ]

  secrets = [ for env in var.sensitive_environment_variables : {
    name  = env.container_app_secret_name
    value = env.value
  } ]

  secret_environment_variables = [ for env in var.sensitive_environment_variables : {
    name  = env.name
    secretRef = env.container_app_secret_name
  } ]

  final_environment_variables = concat(local.environment_variables, local.secret_environment_variables)
}

locals {
  container_registies = [
    {
      server = var.registry_login_server
      identity = var.user_assigned_managed_identity_id
    }
  ]
  containers = [{
    name  = var.container_name
    image = "${var.registry_login_server}/${var.container_image_name}"
    resources = {
      cpu    = var.container_cpu
      memory = var.container_memory
    }
    env = local.final_environment_variables
  }]
}

locals {
  keda_auth = [ for env in var.sensitive_environment_variables : {
    secretRef = env.container_app_secret_name
    triggerParameter = env.keda_auth_name
  } if env.keda_auth_name != null ]

  keda_rule = {
    name = var.keda_rule_type
    type = var.keda_rule_type
    metadata = var.keda_meta_data
    auth = local.keda_auth
  }
}