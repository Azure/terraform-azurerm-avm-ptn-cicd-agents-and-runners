resource "azurerm_container_app_environment" "this" {
  count = local.deploy_container_app && var.container_app_environment_creation_enabled ? 1 : 0

  location                           = var.location
  name                               = local.container_app_environment_name
  resource_group_name                = local.resource_group_name
  infrastructure_resource_group_name = var.use_private_networking ? local.resource_group_name_container_app_infrastructure : null
  infrastructure_subnet_id           = var.use_private_networking ? local.container_app_subnet_id : null
  internal_load_balancer_enabled     = var.use_private_networking ? true : null
  log_analytics_workspace_id         = local.log_analytics_workspace_id
  tags                               = var.tags
  zone_redundancy_enabled            = var.use_private_networking ? true : null

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}
