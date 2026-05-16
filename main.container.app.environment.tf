data "azapi_resource" "log_analytics_workspace" {
  count = local.deploy_container_app && var.container_app_environment_creation_enabled && (var.log_analytics_workspace_creation_enabled || var.log_analytics_workspace_id != null) ? 1 : 0

  resource_id            = local.log_analytics_workspace_id
  type                   = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  response_export_values = ["properties.customerId"]
}

data "azapi_resource_action" "log_analytics_workspace_keys" {
  count = local.deploy_container_app && var.container_app_environment_creation_enabled && (var.log_analytics_workspace_creation_enabled || var.log_analytics_workspace_id != null) ? 1 : 0

  action                 = "sharedKeys"
  method                 = "POST"
  resource_id            = local.log_analytics_workspace_id
  type                   = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  response_export_values = ["primarySharedKey"]
}

resource "azapi_resource" "container_app_environment" {
  count = local.deploy_container_app && var.container_app_environment_creation_enabled ? 1 : 0

  location  = var.location
  name      = local.container_app_environment_name
  parent_id = local.resource_group_id
  type      = "Microsoft.App/managedEnvironments@2024-10-02-preview"
  body = {
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = data.azapi_resource.log_analytics_workspace[0].output.properties.customerId
        }
      }
      vnetConfiguration = var.use_private_networking ? {
        infrastructureSubnetId = local.container_app_subnet_id
        internal               = true
      } : null
      workloadProfiles = [
        {
          name                = "Consumption"
          workloadProfileType = "Consumption"
        }
      ]
      zoneRedundant               = var.use_zone_redundancy ? true : null
      infrastructureResourceGroup = var.use_private_networking ? local.resource_group_name_container_app_infrastructure : null
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_null_property      = true
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values    = ["id", "name"]
  retry                     = var.retry
  schema_validation_enabled = true
  sensitive_body = {
    properties = {
      appLogsConfiguration = {
        logAnalyticsConfiguration = {
          sharedKey = data.azapi_resource_action.log_analytics_workspace_keys[0].output.primarySharedKey
        }
      }
    }
  }
  sensitive_body_version = {
    "properties.appLogsConfiguration.logAnalyticsConfiguration.sharedKey" = "1"
  }
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "time_sleep" "delay_after_container_app_environment_creation" {
  create_duration = "${var.delays.delay_after_container_app_environment_creation}s"

  depends_on = [azapi_resource.container_app_environment]
}

