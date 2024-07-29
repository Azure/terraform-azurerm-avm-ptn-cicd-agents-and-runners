resource "azurerm_container_app_environment" "this" {
  location                       = var.location
  name                           = local.container_app_environment_name
  resource_group_name            = local.resource_group_name
  infrastructure_subnet_id       = local.container_app_subnet_id
  internal_load_balancer_enabled = true
  log_analytics_workspace_id     = local.log_analytics_workspace_id
  tags = var.tags
  zone_redundancy_enabled = true
}
