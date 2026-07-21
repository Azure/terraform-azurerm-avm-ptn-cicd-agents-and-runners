module "container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.5.1"

  location                   = var.location
  name                       = var.name
  resource_group_name        = provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups@2024-11-01", var.parent_id).name
  enable_telemetry           = var.enable_telemetry
  network_rule_bypass_option = var.use_private_networking ? "AzureServices" : "None"
  private_endpoints = var.use_private_networking ? {
    container_registry = {
      private_dns_zone_resource_ids = var.private_dns_zone_id == null || var.private_dns_zone_id == "" ? [] : [var.private_dns_zone_id]
      subnet_resource_id            = var.subnet_id
      tags                          = var.tags
    }
  } : null
  public_network_access_enabled = !var.use_private_networking
  tags                          = var.tags
  zone_redundancy_enabled       = var.use_zone_redundancy
}

resource "azapi_update_resource" "network_rule_bypass_allowed_for_tasks" {
  count = var.use_private_networking ? 1 : 0

  resource_id = module.container_registry.resource_id
  type        = "Microsoft.ContainerRegistry/registries@2025-05-01-preview"
  body = {
    properties = {
      networkRuleBypassAllowedForTasks = true
    }
  }
  retry = var.retry

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

resource "azapi_resource" "task" {
  for_each = var.images

  location  = var.location
  name      = each.value.task_name
  parent_id = module.container_registry.resource_id
  type      = "Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview"
  body = {
    properties = {
      platform = {
        os = "Linux"
      }
      step = {
        type               = "Docker"
        contextPath        = each.value.context_path
        contextAccessToken = each.value.context_access_token
        dockerFilePath     = each.value.dockerfile_path
        imageNames         = each.value.image_names
        isPushEnabled      = true
      }
      credentials = {
        customRegistries = {
          (module.container_registry.resource.login_server) = {
            identity = "[system]"
          }
        }
      }
    }
  }
  response_export_values = ["identity.principalId"]
  retry                  = var.retry
  tags                   = var.tags

  identity {
    type = "SystemAssigned"
  }
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

resource "azurerm_container_registry_task_schedule_run_now" "task_run" {
  for_each = var.images

  container_registry_task_id = azapi_resource.task[each.key].id

  depends_on = [
    azapi_resource.role_assignment_acr_push_for_task,
    azapi_update_resource.network_rule_bypass_allowed_for_tasks
  ]

  lifecycle {
    replace_triggered_by = [azapi_resource.task]
  }
}

resource "azapi_resource" "role_assignment_acr_pull_for_container_instance" {
  name      = uuidv5("dns", "${module.container_registry.resource_id}-${var.container_compute_identity_principal_id}-AcrPull")
  parent_id = module.container_registry.resource_id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = var.container_compute_identity_principal_id
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d"
      principalType    = "ServicePrincipal"
    }
  }
  response_export_values = []
  retry                  = var.retry

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

resource "azapi_resource" "role_assignment_acr_push_for_task" {
  for_each = var.images

  name      = uuidv5("dns", "${module.container_registry.resource_id}-${each.key}-AcrPush")
  parent_id = module.container_registry.resource_id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = azapi_resource.task[each.key].output.identity.principalId
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/8311e382-0749-4cb8-b61a-304f252e45ec"
      principalType    = "ServicePrincipal"
    }
  }
  response_export_values = []
  retry                  = var.retry

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

data "azapi_client_config" "current" {}
