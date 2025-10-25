locals {
  job_container_name         = var.job_container_name == null ? "caj-${var.postfix}" : var.job_container_name
  job_name                   = var.job_name == null ? "caj-${var.postfix}" : var.job_name
  placeholder_container_name = var.placeholder_container_name == null ? "${local.job_container_name}-ph" : var.placeholder_container_name
  placeholder_job_name       = var.placeholder_job_name == null ? "${local.job_name}-ph" : var.placeholder_job_name
}

locals {
  environment_variables = [for env in var.environment_variables : {
    name  = env.name
    value = env.value
  } if env.value != null && env.value != null]
  final_environment_variables = concat(local.environment_variables, local.secret_environment_variables)
  placeholder_environment_variables = [for env in var.environment_variables_placeholder : {
    name  = env.name
    value = env.value
  } if env.value != null && env.value != null]
  secret_environment_variables = [for env in var.sensitive_environment_variables : {
    name      = env.name
    secretRef = env.container_app_secret_name
  } if env.value != null && env.value != null]
  secrets = concat([for env in var.sensitive_environment_variables : {
    name  = env.container_app_secret_name
    value = env.value
    } if env.value != null && env.value != null],
    var.registry_password == null ? [] : [{
      name  = "registry-password"
      value = var.registry_password
  }])
}

locals {
  container_job = {
    name  = local.job_container_name
    image = "${var.registry_login_server}/${var.container_image_name}"
    resources = {
      cpu    = var.container_cpu
      memory = var.container_memory
    }
    env = local.final_environment_variables
  }
  container_placeholder = {
    name  = local.placeholder_container_name
    image = "${var.registry_login_server}/${var.container_image_name}"
    resources = {
      cpu    = var.container_cpu
      memory = var.container_memory
    }
    env = concat(local.final_environment_variables, local.placeholder_environment_variables)
  }
  container_registies = var.registry_password == null ? [
    {
      server   = var.registry_login_server
      identity = var.user_assigned_managed_identity_id
    }
    ] : [
    {
      server            = var.registry_login_server
      username          = var.registry_username
      passwordSecretRef = "registry-password"
    }
  ]
}

locals {
  keda_auth = [for env in var.sensitive_environment_variables : {
    secretRef        = env.container_app_secret_name
    triggerParameter = env.keda_auth_name
  } if env.keda_auth_name != null]
  keda_rule = merge({
    name     = var.keda_rule_type
    type     = var.keda_rule_type
    metadata = var.keda_meta_data
    auth     = local.keda_auth
    }, var.use_managed_identity_auth ? {
    identity = var.user_assigned_managed_identity_id
  } : {})
}
