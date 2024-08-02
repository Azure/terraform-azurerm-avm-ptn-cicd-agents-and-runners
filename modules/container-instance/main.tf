resource "azurerm_container_group" "alz" {
  location            = var.location
  name                = var.container_instance_name
  os_type             = "Linux"
  resource_group_name = var.resource_group_name
  ip_address_type     = var.use_private_networking ? "Private" : "None"
  subnet_ids          = var.use_private_networking ? [var.subnet_id] : []
  tags                = var.tags
  zones               = var.availability_zones

  container {
    cpu                          = var.container_cpu
    image                        = "${var.container_registry_login_server}/${var.container_image}"
    memory                       = var.container_memory
    name                         = var.container_name
    cpu_limit                    = var.container_cpu_limit
    environment_variables        = var.environment_variables
    memory_limit                 = var.container_memory_limit
    secure_environment_variables = var.sensitive_environment_variables

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }
  dynamic "image_registry_credential" {
    for_each = var.container_registry_username != null ? ["custom"] : []
    content {
      server   = var.container_registry_login_server
      password = var.container_registry_password
      username = var.container_registry_username
    }
  }
  dynamic "image_registry_credential" {
    for_each = var.container_registry_username == null ? ["default"] : []
    content {
      server                    = var.container_registry_login_server
      user_assigned_identity_id = var.user_assigned_managed_identity_id
    }
  }
}
