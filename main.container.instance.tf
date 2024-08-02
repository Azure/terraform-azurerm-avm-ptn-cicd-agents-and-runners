module "container_instance" {
  source                            = "./modules/container-instance"
  for_each                          = local.deploy_container_instance ? local.container_instances : {}
  location                          = var.location
  resource_group_name               = local.resource_group_name
  container_instance_name           = each.value.name
  container_name                    = local.container_instance_container_name
  container_image                   = local.container_images["container_instance"].image_names[0]
  container_cpu                     = var.container_instance_container_cpu
  container_memory                  = var.container_instance_container_memory
  container_cpu_limit               = var.container_instance_container_cpu_limit
  container_memory_limit            = var.container_instance_container_memory_limit
  environment_variables             = merge({ for key, value in local.container_instance_environment_variables_map : key => value if !endswith(value, "%s") }, { for key, value in local.container_instance_environment_variables_map : key => format(value, each.key) if endswith(value, "%s") })
  sensitive_environment_variables   = local.container_instance_sensitive_environment_variables_map
  use_private_networking            = var.use_private_networking
  subnet_id                         = local.container_instance_subnet_id
  availability_zones                = each.value.availability_zones
  user_assigned_managed_identity_id = local.user_assigned_managed_identity_id
  container_registry_login_server   = local.registry_login_server
  container_registry_username       = var.custom_container_registry_username
  container_registry_password       = var.custom_container_registry_password
}

