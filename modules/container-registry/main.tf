module "container_registry" {
  source                        = "Azure/avm-res-containerregistry-registry/azurerm"
  version                       = "0.2.0"
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.use_private_networking ? "Premium" : "Basic"
  public_network_access_enabled = !var.use_private_networking
  zone_redundancy_enabled       = var.use_private_networking
  network_rule_bypass_option    = var.use_private_networking ? "AzureServices" : "None"
  enable_telemetry              = var.enable_telemetry
  private_endpoints = var.use_private_networking ? {
    container_registry = {
      private_dns_zone_resource_ids = [var.private_dns_zone_id]
      subnet_resource_id            = var.subnet_id
    }
  } : null
  tags = var.tags
}

resource "azurerm_container_registry_task" "this" {
  for_each = var.images

  container_registry_id = module.container_registry.resource_id
  name                  = each.value.task_name
  tags                  = var.tags

  docker_step {
    context_access_token = each.value.context_access_token
    context_path         = each.value.context_path
    dockerfile_path      = each.value.dockerfile_path
    image_names          = each.value.image_names
  }
  identity {
    type = "SystemAssigned" # Note this has to be a System Assigned Identity to work with private networking and `network_rule_bypass_option` set to `AzureServices`
  }
  platform {
    os = "Linux"
  }
  registry_credential {
    custom {
      login_server = module.container_registry.resource.login_server
      identity     = "[system]"
    }
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "this" {
  for_each = var.images

  container_registry_task_id = azurerm_container_registry_task.this[each.key].id

  depends_on = [azurerm_role_assignment.container_registry_push_for_task]

  lifecycle {
    replace_triggered_by = [azurerm_container_registry_task.this]
  }
}

resource "azurerm_role_assignment" "container_registry_pull_for_container_instance" {
  principal_id         = var.container_compute_identity_principal_id
  scope                = module.container_registry.resource_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "container_registry_push_for_task" {
  for_each = var.images

  principal_id         = azurerm_container_registry_task.this[each.key].identity[0].principal_id
  scope                = module.container_registry.resource_id
  role_definition_name = "AcrPush"
}
