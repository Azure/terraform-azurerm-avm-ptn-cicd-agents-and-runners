module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.4.2"
  count   = var.log_analytics_workspace_creation_enabled && local.deploy_container_app ? 1 : 0

  location                                  = var.location
  name                                      = local.log_analytics_workspace_name
  resource_group_name                       = local.resource_group_name
  log_analytics_workspace_retention_in_days = var.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku               = var.log_analytics_workspace_sku
  tags                                      = var.tags
}
