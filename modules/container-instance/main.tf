resource "azurerm_container_group" "alz" {
  name                = var.container_instance_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = var.use_private_networking ? "Private" : "None"
  os_type             = "Linux"
  subnet_ids          = var.use_private_networking ? [var.subnet_id] : []
  zones               = var.availability_zones

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }

  image_registry_credential {
    server                    = var.container_registry_login_server
    user_assigned_identity_id = var.user_assigned_managed_identity_id
  }

  container {
    name  = var.container_name
    image = "${var.container_registry_login_server}/${var.container_image}"

    cpu          = var.container_cpu
    memory       = var.container_memory
    cpu_limit    = var.container_cpu_limit
    memory_limit = var.container_memory_limit

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = var.environment_variables
    secure_environment_variables = var.sensitive_environment_variables
  }
}
