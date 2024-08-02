<!-- BEGIN_TF_DOCS -->
# CI/CD Agents and Runners - Container Instance

This submodule deploys an Azure Container Instance for CI/CD agents and runners.

```hcl
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.113)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.113)

## Resources

The following resources are used by this module:

- [azurerm_container_group.alz](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_container_image"></a> [container\_image](#input\_container\_image)

Description: Image of the container

Type: `string`

### <a name="input_container_instance_name"></a> [container\_instance\_name](#input\_container\_instance\_name)

Description: Name of the container instance

Type: `string`

### <a name="input_container_name"></a> [container\_name](#input\_container\_name)

Description: Name of the container

Type: `string`

### <a name="input_container_registry_login_server"></a> [container\_registry\_login\_server](#input\_container\_registry\_login\_server)

Description: Login server of the container registry

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Name of the resource group

Type: `string`

### <a name="input_user_assigned_managed_identity_id"></a> [user\_assigned\_managed\_identity\_id](#input\_user\_assigned\_managed\_identity\_id)

Description: ID of the user-assigned managed identity

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones)

Description: List of availability zones

Type: `list(string)`

Default:

```json
[
  1
]
```

### <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu)

Description: CPU value for the container

Type: `number`

Default: `2`

### <a name="input_container_cpu_limit"></a> [container\_cpu\_limit](#input\_container\_cpu\_limit)

Description: CPU limit for the container

Type: `number`

Default: `2`

### <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory)

Description: Memory value for the container

Type: `number`

Default: `4`

### <a name="input_container_memory_limit"></a> [container\_memory\_limit](#input\_container\_memory\_limit)

Description: Memory limit for the container

Type: `number`

Default: `4`

### <a name="input_container_registry_password"></a> [container\_registry\_password](#input\_container\_registry\_password)

Description: Password of the container registry

Type: `string`

Default: `null`

### <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username)

Description: Username of the container registry

Type: `string`

Default: `null`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: Environment variables for the container

Type: `map(string)`

Default: `{}`

### <a name="input_sensitive_environment_variables"></a> [sensitive\_environment\_variables](#input\_sensitive\_environment\_variables)

Description: Secure environment variables for the container

Type: `map(string)`

Default: `{}`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: ID of the subnet

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_use_private_networking"></a> [use\_private\_networking](#input\_use\_private\_networking)

Description: Flag to indicate whether to use private networking

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the container instance

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The container instance resource

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the container instance

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->