module "container_instance" {
  source   = "./modules/container-instance"
  for_each = local.deploy_container_instance ? local.container_instances : {}

  container_image                   = local.container_images["container_instance"].image_names[0]
  container_instance_name           = each.value.name
  container_name                    = local.container_instance_container_name
  container_registry_login_server   = local.registry_login_server
  location                          = var.location
  parent_id                         = local.resource_group_id
  user_assigned_managed_identity_id = local.user_assigned_managed_identity_id
  availability_zones                = var.container_instance_use_availability_zones ? each.value.availability_zones : null
  container_cpu                     = var.container_instance_container_cpu
  container_cpu_limit               = var.container_instance_container_cpu_limit
  container_memory                  = var.container_instance_container_memory
  container_memory_limit            = var.container_instance_container_memory_limit
  container_registry_password       = var.custom_container_registry_password
  container_registry_username       = var.custom_container_registry_username
  environment_variables             = merge({ for key, value in local.container_instance_environment_variables_map : key => value if !endswith(value, "%s") }, { for key, value in local.container_instance_environment_variables_map : key => format(value, each.key) if endswith(value, "%s") })
  retry                             = var.retry
  sensitive_environment_variables   = local.container_instance_sensitive_environment_variables_map
  subnet_id                         = local.container_instance_subnet_id
  timeouts                          = var.timeouts
  use_private_networking            = var.use_private_networking

  depends_on = [azapi_resource.custom_container_registry_pull, azapi_resource.private_dns_zone_virtual_network_link_container_registry, time_sleep.delay_after_container_image_build]
}

