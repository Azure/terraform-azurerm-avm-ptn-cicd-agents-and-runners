<!-- BEGIN_TF_DOCS -->
# CI/CD Agents and Runners - Container Registry

This submodule deploys an Azure Container Registry and image build tasks for CI/CD agents and runners.

```hcl
module "container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.4.0"

  location                   = var.location
  name                       = var.name
  resource_group_name        = var.resource_group_name
  enable_telemetry           = var.enable_telemetry
  network_rule_bypass_option = var.use_private_networking ? "AzureServices" : "None"
  private_endpoints = var.use_private_networking ? {
    container_registry = {
      private_dns_zone_resource_ids = var.private_dns_zone_id == null || var.private_dns_zone_id == "" ? [] : [var.private_dns_zone_id]
      subnet_resource_id            = var.subnet_id
    }
  } : null
  public_network_access_enabled = !var.use_private_networking
  tags                          = var.tags
  zone_redundancy_enabled       = var.use_zone_redundancy ? true : null
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

  depends_on = [
    azurerm_role_assignment.container_registry_push_for_task,
    azapi_update_resource.network_rule_bypass_allowed_for_tasks
  ]

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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.20)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~> 2.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.20)

## Resources

The following resources are used by this module:

- [azapi_update_resource.network_rule_bypass_allowed_for_tasks](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource) (resource)
- [azurerm_container_registry_task.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task) (resource)
- [azurerm_container_registry_task_schedule_run_now.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task_schedule_run_now) (resource)
- [azurerm_role_assignment.container_registry_pull_for_container_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.container_registry_push_for_task](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_container_compute_identity_principal_id"></a> [container\_compute\_identity\_principal\_id](#input\_container\_compute\_identity\_principal\_id)

Description: The principal id of the managed identity used by the container compute to pull images from the container registry

Type: `string`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: Whether to enable telemetry for the container registry

Type: `bool`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the container registry

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the container registry

Type: `string`

### <a name="input_use_private_networking"></a> [use\_private\_networking](#input\_use\_private\_networking)

Description: Whether to use private networking for the container registry

Type: `bool`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_images"></a> [images](#input\_images)

Description: A map of objects that define the images to build in the container registry. The key of the map is the name of the image and the value is an object with the following attributes:

- `task_name` - The name of the task to create for building the image (e.g. `image-build-task`)
- `dockerfile_path` - The path to the Dockerfile to use for building the image (e.g. `dockerfile`)
- `context_path` - The path to the context of the Dockerfile in three sections `<repository-url>#<repository-commit>:<repository-folder-path>` (e.g. https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners#8ff4b85:container-images/azure-devops-agent)
- `context_access_token` - The access token to use for accessing the context. Supply a PAT if targetting a private repository.
- `image_names` - A list of the names of the images to build (e.g. `["image-name:tag"]`)

Type:

```hcl
map(object({
    task_name            = string
    dockerfile_path      = string
    context_path         = string
    context_access_token = optional(string, "a") # This `a` is a dummy value because the context_access_token should not be required in the provider
    image_names          = list(string)
  }))
```

Default: `{}`

### <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id)

Description: The id of the private DNS zone to create for the container registry. Only required if `container_registry_private_dns_zone_creation_enabled` is `false` and you are not using policy to update the DNS zone.

Type: `string`

Default: `null`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The id of the subnet to use for the private endpoint

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_use_zone_redundancy"></a> [use\_zone\_redundancy](#input\_use\_zone\_redundancy)

Description: Whether to use zone redundancy for the container registry. Defaults to true.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_login_server"></a> [login\_server](#output\_login\_server)

Description: The login server of the container registry

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the container registry

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the container registry

## Modules

The following Modules are called:

### <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry)

Source: Azure/avm-res-containerregistry-registry/azurerm

Version: 0.4.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->