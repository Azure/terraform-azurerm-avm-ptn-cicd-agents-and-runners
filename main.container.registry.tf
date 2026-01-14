module "container_registry" {
  source = "./modules/container-registry"
  count  = var.container_registry_creation_enabled ? 1 : 0

  container_compute_identity_principal_id = local.user_assigned_managed_identity_principal_id
  enable_telemetry                        = var.enable_telemetry
  location                                = var.location
  name                                    = local.container_registry_name
  resource_group_name                     = local.resource_group_name
  use_private_networking                  = var.use_private_networking
  images                                  = local.container_images
  private_dns_zone_id                     = local.container_registry_dns_zone_id
  subnet_id                               = local.container_registry_private_endpoint_subnet_id
  tags                                    = var.tags
  use_zone_redundancy                     = var.use_zone_redundancy ? true : null
}

resource "azurerm_role_assignment" "container_registry_pull_for_container_instance" {
  count = var.user_assigned_managed_identity_creation_enabled && var.custom_container_registry_id != null ? 1 : 0

  principal_id         = local.user_assigned_managed_identity_principal_id
  scope                = var.custom_container_registry_id
  role_definition_name = "AcrPull"
}

resource "time_sleep" "delay_after_container_image_build" {
  create_duration = "${var.delays.delay_after_container_image_build}s"

  depends_on = [module.container_registry]
}
