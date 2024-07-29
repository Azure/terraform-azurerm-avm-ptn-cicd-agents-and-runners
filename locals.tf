locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  resource_group_name = var.resource_group_creation_enabled ? azurerm_resource_group.this[0].name : var.resource_group_name
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}"
  subnet_id = var.create_virtual_network ? module.virtual_network[0].subnets["agents"].resource_id : var.subnet_id
  log_analytics_workspace_id = var.create_log_analytics_workspace ? module.log_analytics_workspace[0].resource_id : var.log_analytics_workspace_id
  user_assigned_managed_identity_principal_id = var.create_user_assigned_managed_identity ? module.user_assigned_managed_identity[0].principal_id : var.user_assigned_managed_identity_principal_id
}

locals {
  container_app_environment_name = var.container_app_environment_name != null ? var.container_app_environment_name : "cae-${var.postfix}"
  container_registry_name = var.container_registry_name != null ? var.container_registry_name : "acr-${var.postfix}"
  log_analytics_workspace_name = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : "laws-${var.postfix}"
  virtual_network_name = var.virtual_network_name != null ? var.virtual_network_name : "vnet-${var.postfix}"
  subnet_name = var.subnet_name != null ? var.subnet_name : "subnet-${var.postfix}"
  user_assigned_managed_identity_name = var.user_assigned_managed_identity_name != null ? var.user_assigned_managed_identity_name : "uami-${var.postfix}"
  user_assigned_managed_identity_id = var.user_assigned_managed_identity_id != null ? var.user_assigned_managed_identity_id : module.user_assigned_managed_identity[0].resource_id
}

locals {
  version_control_system_azure_devops = "azuredevops"
  version_control_system_github = "github"
  default_image_name = var.default_image_name != null ? var.default_image_name : (var.version_control_system_type == local.version_control_system_azure_devops ? "azure-devops-agent" : "github-runner")
  container_images = var.use_default_container_image ? {
    default = {
        task_name = "${var.version_control_system_type}-image-build-task"
        dockerfile_path = var.default_image_registry_dockerfile_path
        context_path = "${var.default_image_repository_url}#${var.default_image_repository_commit}:${var.default_image_repository_folder_path}"
        context_access_token = "a"
        image_names = ["${local.default_image_name}:${var.default_image_repository_commit}"]
    }
} : { default = var.custom_container_registry_image }
}