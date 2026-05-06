resource "azapi_resource" "container_group" {
  location  = var.location
  name      = var.container_instance_name
  parent_id = var.parent_id
  type      = "Microsoft.ContainerInstance/containerGroups@2024-05-01-preview"
  body = {
    zones = var.availability_zones
    properties = {
      osType = "Linux"
      ipAddress = var.use_private_networking ? {
        type = "Private"
        ports = [
          {
            port     = 80
            protocol = "TCP"
          }
        ]
      } : null
      subnetIds = var.use_private_networking ? [{ id = var.subnet_id }] : null
      containers = [
        {
          name = var.container_name
          properties = {
            image = "${var.container_registry_login_server}/${var.container_image}"
            resources = {
              requests = {
                cpu        = var.container_cpu
                memoryInGB = var.container_memory
              }
              limits = {
                cpu        = var.container_cpu_limit
                memoryInGB = var.container_memory_limit
              }
            }
            environmentVariables = concat(
              [for k, v in var.environment_variables : { name = k, value = v }],
              [for k, v in var.sensitive_environment_variables : { name = k, secureValue = v }]
            )
            ports = [
              {
                port     = 80
                protocol = "TCP"
              }
            ]
          }
        }
      ]
      imageRegistryCredentials = var.container_registry_username != null ? [
        {
          server   = var.container_registry_login_server
          username = var.container_registry_username
          password = var.container_registry_password
        }
        ] : [
        {
          server   = var.container_registry_login_server
          identity = var.user_assigned_managed_identity_id
        }
      ]
    }
  }
  response_export_values = ["id", "name"]
  tags                   = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }
}
