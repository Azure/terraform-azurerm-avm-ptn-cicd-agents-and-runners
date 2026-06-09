module "container_registry" {
  source = "./modules/container-registry"
  count  = var.container_registry_creation_enabled ? 1 : 0

  container_compute_identity_principal_id = local.user_assigned_managed_identity_principal_id
  enable_telemetry                        = var.enable_telemetry
  location                                = var.location
  name                                    = local.container_registry_name
  parent_id                               = local.resource_group_id
  use_private_networking                  = var.use_private_networking
  images                                  = local.container_images
  private_dns_zone_id                     = local.container_registry_dns_zone_id
  retry                                   = var.retry
  subnet_id                               = local.container_registry_private_endpoint_subnet_id
  tags                                    = var.tags
  timeouts                                = var.timeouts
  use_zone_redundancy                     = var.use_zone_redundancy
}

resource "azapi_resource" "custom_container_registry_pull" {
  count = var.custom_container_registry_id != null ? 1 : 0

  name      = uuidv5("dns", "${var.custom_container_registry_id}-${local.user_assigned_managed_identity_principal_id}-AcrPull")
  parent_id = var.custom_container_registry_id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = local.user_assigned_managed_identity_principal_id
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.role_definition_ids.acr_pull}"
      principalType    = "ServicePrincipal"
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

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

resource "azapi_resource" "runner_acr_push" {
  count = var.container_registry_creation_enabled && var.runner_acr_push_enabled ? 1 : 0

  name      = uuidv5("dns", "${module.container_registry[0].resource_id}-${local.user_assigned_managed_identity_principal_id}-AcrPush")
  parent_id = module.container_registry[0].resource_id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId      = local.user_assigned_managed_identity_principal_id
      roleDefinitionId = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.role_definition_ids.acr_push}"
      principalType    = "ServicePrincipal"
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

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

resource "time_sleep" "delay_after_container_image_build" {
  create_duration = "${var.delays.delay_after_container_image_build}s"

  depends_on = [module.container_registry]
}
