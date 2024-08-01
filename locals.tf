locals {
  container_app_environment_id                     = local.deploy_container_app && var.create_container_app_environment ? azurerm_container_app_environment.this[0].id : var.container_app_environment_id
  container_app_subnet_id                          = var.use_private_networking && local.deploy_container_app ? (var.create_virtual_network ? module.virtual_network[0].subnets["container_app"].resource_id : var.container_app_subnet_id) : ""
  container_instance_subnet_id                     = var.use_private_networking && local.deploy_container_instance ? (var.create_virtual_network ? module.virtual_network[0].subnets["container_instance"].resource_id : var.container_instance_subnet_id) : ""
  container_registry_dns_zone_id                   = var.use_private_networking ? (var.create_container_registry_private_dns_zone ? azurerm_private_dns_zone.container_registry[0].id : var.container_registry_dns_zone_id) : ""
  container_registry_private_endpoint_subnet_id    = var.use_private_networking ? (var.create_virtual_network ? module.virtual_network[0].subnets["container_registry_private_endpoint"].resource_id : var.container_registry_private_endpoint_subnet_id) : ""
  log_analytics_workspace_id                       = local.deploy_container_app && var.create_log_analytics_workspace ? module.log_analytics_workspace[0].resource_id : var.log_analytics_workspace_id
  nat_gateway_id                                   = var.use_private_networking ? (var.create_nat_gateway ? azurerm_nat_gateway.this[0].id : var.nat_gateway_id) : ""
  public_ip_id                                     = var.use_private_networking ? (var.create_public_ip ? azurerm_public_ip.this[0].id : var.public_ip_id) : ""
  registry_login_server                            = var.create_container_registry ? module.container_registry[0].login_server : var.custom_container_registry_login_server
  resource_group_id                                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}"
  resource_group_name                              = var.resource_group_creation_enabled ? azurerm_resource_group.this[0].name : var.resource_group_name
  resource_group_name_container_app_infrastructure = var.container_app_infrastructure_resource_group_name == null ? "rg-${var.postfix}-container-apps-infrastructure" : var.container_app_infrastructure_resource_group_name
  role_definition_resource_substring               = "/providers/Microsoft.Authorization/roleDefinitions"
  user_assigned_managed_identity_principal_id      = var.create_user_assigned_managed_identity ? module.user_assigned_managed_identity[0].principal_id : var.user_assigned_managed_identity_principal_id
}

locals {
  container_app_environment_name                  = var.create_container_app_environment ? (var.container_app_environment_name != null ? var.container_app_environment_name : "cae-${var.postfix}") : ""
  container_app_subnet_name                       = var.container_app_subnet_name != null ? var.container_app_subnet_name : "subnet-container-app-${var.postfix}"
  container_instance_container_name               = var.container_instance_container_name != null ? var.container_instance_container_name : "container-${var.postfix}"
  container_instance_name_prefix                  = var.container_instance_name_prefix != null ? var.container_instance_name_prefix : "ci-${var.postfix}"
  container_instance_subnet_name                  = var.container_instance_subnet_name != null ? var.container_instance_subnet_name : "subnet-container-instance-${var.postfix}"
  container_registry_name                         = var.container_registry_name != null ? var.container_registry_name : "acr${var.postfix}"
  container_registry_private_endpoint_subnet_name = var.container_registry_private_endpoint_subnet_name != null ? var.container_registry_private_endpoint_subnet_name : "subnet-container-registry-private-endpoint-${var.postfix}"
  github_repository_url                           = var.version_control_system_repository != null ? (startswith(var.version_control_system_repository, "https") ? var.version_control_system_repository : "https://github.com/${var.version_control_system_organization}/${var.version_control_system_repository}") : ""
  log_analytics_workspace_name                    = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : "laws-${var.postfix}"
  nat_gateway_name                                = var.nat_gateway_name != null ? var.nat_gateway_name : "natgw-${var.postfix}"
  public_ip_name                                  = var.public_ip_name != null ? var.public_ip_name : "pip-${var.postfix}"
  user_assigned_managed_identity_id               = var.user_assigned_managed_identity_id != null ? var.user_assigned_managed_identity_id : module.user_assigned_managed_identity[0].resource_id
  user_assigned_managed_identity_name             = var.user_assigned_managed_identity_name != null ? var.user_assigned_managed_identity_name : "uami-${var.postfix}"
  version_control_system_agent_name_prefix        = var.version_control_system_agent_name_prefix != null ? var.version_control_system_agent_name_prefix : (var.version_control_system_type == local.version_control_system_azure_devops ? "agent-${var.postfix}" : "runner-${var.postfix}")
  virtual_network_name                            = var.virtual_network_name != null ? var.virtual_network_name : "vnet-${var.postfix}"
}

locals {
  container_app_default_container_image = local.deploy_container_app ? {
    container_app = {
      task_name            = "${var.version_control_system_type}-container-app-image-build-task"
      dockerfile_path      = var.default_image_registry_dockerfile_path
      context_path         = "${var.default_image_repository_url}#${var.default_image_repository_commit}:${var.default_image_repository_folder_paths["${var.version_control_system_type}-container-app"]}"
      context_access_token = "a"
      image_names          = ["${local.default_image_name}:${var.default_image_repository_commit}"]
    }
  } : {}
  container_images = var.use_default_container_image ? merge(local.container_app_default_container_image, local.container_instance_default_container_image) : var.custom_container_registry_images
  container_instance_default_container_image = local.deploy_container_instance ? {
    container_instance = {
      task_name            = "${var.version_control_system_type}-container-instance-image-build-task"
      dockerfile_path      = var.default_image_registry_dockerfile_path
      context_path         = "${var.default_image_repository_url}#${var.default_image_repository_commit}:${var.default_image_repository_folder_paths["${var.version_control_system_type}-container-instance"]}"
      context_access_token = "a"
      image_names          = ["${local.default_image_name}:${var.default_image_repository_commit}"]
    }
  } : {}
  default_image_name                  = var.default_image_name != null ? var.default_image_name : (var.version_control_system_type == local.version_control_system_azure_devops ? "azure-devops-agent" : "github-runner")
  version_control_system_azure_devops = "azuredevops"
  version_control_system_github       = "github"
}

locals {
  deploy_container_app      = contains(var.compute_types, "azure_container_app")
  deploy_container_instance = contains(var.compute_types, "azure_container_instance")
}
