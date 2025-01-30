<!-- BEGIN_TF_DOCS -->
# Azure Verified Module for CI/CD Agents and Runners

This module deploys self-hosted Azure DevOps Agents and Github Runners.

## Features

- Deploys and configures Azure DevOps Agents
- Deploys and configures Github Runners
- Supports Azure Container Apps with auto scaling from zero
- Supports Azure Container Instances as an alternative or complementary compute option
- Supports Public or Private Networking
- Deploys all Azure resource required or optionally supply your own

## Example Usage

This example shows how to deploy Azure DevOps Agents to Azure Container Apps using the minimal set of required variables with private networking.

```hcl
module "azure_devops_agents" {
  source                                       = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version                                      = "~> 0.2"
  postfix                                      = "my-agents"
  location                                     = "uksouth"
  version_control_system_type                  = "azuredevops"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_pool_name             = "my-agent-pool"
  virtual_network_address_space                = "10.0.0.0/16"
}
```

This example shows how to deploy GitHub Runners to Azure Container Apps using the minimal set of required variables with private networking.

```hcl
module "github_runners" {
  source                                       = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version                                      = "~> 0.2"
  postfix                                      = "my-runners"
  location                                     = "uksouth"
  version_control_system_type                  = "github"
  version_control_system_personal_access_token = "**************************************"
  version_control_system_organization          = "my-organization"
  version_control_system_repository            = "my-reository"
  virtual_network_address_space                = "10.0.0.0/16"
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.113)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.12)

## Resources

The following resources are used by this module:

- [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) (resource)
- [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) (resource)
- [azurerm_private_dns_zone.container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [time_sleep.delay_after_container_image_build](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_postfix"></a> [postfix](#input\_postfix)

Description: A postfix used to build default names if no name has been supplied for a specific resource type.

Type: `string`

### <a name="input_version_control_system_organization"></a> [version\_control\_system\_organization](#input\_version\_control\_system\_organization)

Description: The version control system organization to deploy the agents too.

Type: `string`

### <a name="input_version_control_system_personal_access_token"></a> [version\_control\_system\_personal\_access\_token](#input\_version\_control\_system\_personal\_access\_token)

Description: The personal access token for the version control system.

Type: `string`

### <a name="input_version_control_system_type"></a> [version\_control\_system\_type](#input\_version\_control\_system\_type)

Description: The type of the version control system to deploy the agents too. Allowed values are 'azuredevops' or 'github'

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_compute_types"></a> [compute\_types](#input\_compute\_types)

Description: The types of compute to use. Allowed values are 'azure\_container\_app' and 'azure\_container\_instance'.

Type: `set(string)`

Default:

```json
[
  "azure_container_app"
]
```

### <a name="input_container_app_container_cpu"></a> [container\_app\_container\_cpu](#input\_container\_app\_container\_cpu)

Description: Required CPU in cores, e.g. 0.5

Type: `number`

Default: `1`

### <a name="input_container_app_container_memory"></a> [container\_app\_container\_memory](#input\_container\_app\_container\_memory)

Description: Required memory, e.g. '250Mb'

Type: `string`

Default: `"2Gi"`

### <a name="input_container_app_environment_creation_enabled"></a> [container\_app\_environment\_creation\_enabled](#input\_container\_app\_environment\_creation\_enabled)

Description: Whether or not to create a Container App Environment.

Type: `bool`

Default: `true`

### <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id)

Description: The resource id of the Container App Environment. Only required if `container_app_environment_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_container_app_environment_name"></a> [container\_app\_environment\_name](#input\_container\_app\_environment\_name)

Description: The name of the Container App Environment. Only required if `container_app_environment_creation_enabled` is `true`.

Type: `string`

Default: `null`

### <a name="input_container_app_environment_variables"></a> [container\_app\_environment\_variables](#input\_container\_app\_environment\_variables)

Description: List of additional environment variables to pass to the container.

Type:

```hcl
set(object({
    name  = string
    value = string
  }))
```

Default: `[]`

### <a name="input_container_app_infrastructure_resource_group_name"></a> [container\_app\_infrastructure\_resource\_group\_name](#input\_container\_app\_infrastructure\_resource\_group\_name)

Description: The name of the resource group where the Container Apps infrastructure is deployed.

Type: `string`

Default: `null`

### <a name="input_container_app_job_container_name"></a> [container\_app\_job\_container\_name](#input\_container\_app\_job\_container\_name)

Description: The name of the container for the runner Container Apps job.

Type: `string`

Default: `null`

### <a name="input_container_app_job_name"></a> [container\_app\_job\_name](#input\_container\_app\_job\_name)

Description: The name of the Container App runner job.

Type: `string`

Default: `null`

### <a name="input_container_app_max_execution_count"></a> [container\_app\_max\_execution\_count](#input\_container\_app\_max\_execution\_count)

Description: The maximum number of executions (ADO jobs) to spawn per polling interval.

Type: `number`

Default: `100`

### <a name="input_container_app_min_execution_count"></a> [container\_app\_min\_execution\_count](#input\_container\_app\_min\_execution\_count)

Description: The minimum number of executions (ADO jobs) to spawn per polling interval.

Type: `number`

Default: `0`

### <a name="input_container_app_placeholder_container_name"></a> [container\_app\_placeholder\_container\_name](#input\_container\_app\_placeholder\_container\_name)

Description: The name of the container for the placeholder Container Apps job.

Type: `string`

Default: `null`

### <a name="input_container_app_placeholder_job_name"></a> [container\_app\_placeholder\_job\_name](#input\_container\_app\_placeholder\_job\_name)

Description: The name of the Container App placeholder job.

Type: `string`

Default: `null`

### <a name="input_container_app_placeholder_replica_retry_limit"></a> [container\_app\_placeholder\_replica\_retry\_limit](#input\_container\_app\_placeholder\_replica\_retry\_limit)

Description: The number of times to retry the placeholder Container Apps job.

Type: `number`

Default: `0`

### <a name="input_container_app_placeholder_replica_timeout"></a> [container\_app\_placeholder\_replica\_timeout](#input\_container\_app\_placeholder\_replica\_timeout)

Description: The timeout in seconds for the placeholder Container Apps job.

Type: `number`

Default: `300`

### <a name="input_container_app_polling_interval_seconds"></a> [container\_app\_polling\_interval\_seconds](#input\_container\_app\_polling\_interval\_seconds)

Description: How often should the pipeline queue be checked for new events, in seconds.

Type: `number`

Default: `30`

### <a name="input_container_app_replica_retry_limit"></a> [container\_app\_replica\_retry\_limit](#input\_container\_app\_replica\_retry\_limit)

Description: The number of times to retry the runner Container Apps job.

Type: `number`

Default: `3`

### <a name="input_container_app_replica_timeout"></a> [container\_app\_replica\_timeout](#input\_container\_app\_replica\_timeout)

Description: The timeout in seconds for the runner Container Apps job.

Type: `number`

Default: `1800`

### <a name="input_container_app_sensitive_environment_variables"></a> [container\_app\_sensitive\_environment\_variables](#input\_container\_app\_sensitive\_environment\_variables)

Description: List of additional sensitive environment variables to pass to the container.

Type:

```hcl
set(object({
    name                      = string
    value                     = string
    container_app_secret_name = string
    keda_auth_name            = optional(string)
  }))
```

Default: `[]`

### <a name="input_container_app_subnet_address_prefix"></a> [container\_app\_subnet\_address\_prefix](#input\_container\_app\_subnet\_address\_prefix)

Description: The address prefix for the Container App Environment. Either subnet\_id or subnet\_name and subnet\_address\_prefix must be specified.

Type: `string`

Default: `null`

### <a name="input_container_app_subnet_cidr_size"></a> [container\_app\_subnet\_cidr\_size](#input\_container\_app\_subnet\_cidr\_size)

Description: The CIDR size for the container instance subnet.

Type: `number`

Default: `27`

### <a name="input_container_app_subnet_id"></a> [container\_app\_subnet\_id](#input\_container\_app\_subnet\_id)

Description: The ID of a pre-existing subnet to use. Required if `virtual_network_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_container_app_subnet_name"></a> [container\_app\_subnet\_name](#input\_container\_app\_subnet\_name)

Description: The name of the subnet. Must be specified if `virtual_network_creation_enabled` is `true`.

Type: `string`

Default: `null`

### <a name="input_container_instance_container_cpu"></a> [container\_instance\_container\_cpu](#input\_container\_instance\_container\_cpu)

Description: The CPU value for the container instance

Type: `number`

Default: `2`

### <a name="input_container_instance_container_cpu_limit"></a> [container\_instance\_container\_cpu\_limit](#input\_container\_instance\_container\_cpu\_limit)

Description: The CPU limit value for the container instance

Type: `number`

Default: `2`

### <a name="input_container_instance_container_memory"></a> [container\_instance\_container\_memory](#input\_container\_instance\_container\_memory)

Description: The memory value for the container instance

Type: `number`

Default: `4`

### <a name="input_container_instance_container_memory_limit"></a> [container\_instance\_container\_memory\_limit](#input\_container\_instance\_container\_memory\_limit)

Description: The memory limit value for the container instance

Type: `number`

Default: `4`

### <a name="input_container_instance_container_name"></a> [container\_instance\_container\_name](#input\_container\_instance\_container\_name)

Description: The name of the container instance

Type: `string`

Default: `null`

### <a name="input_container_instance_count"></a> [container\_instance\_count](#input\_container\_instance\_count)

Description: The number of container instances to create

Type: `number`

Default: `2`

### <a name="input_container_instance_environment_variables"></a> [container\_instance\_environment\_variables](#input\_container\_instance\_environment\_variables)

Description: List of additional environment variables to pass to the container.

Type:

```hcl
set(object({
    name  = string
    value = string
  }))
```

Default: `[]`

### <a name="input_container_instance_name_prefix"></a> [container\_instance\_name\_prefix](#input\_container\_instance\_name\_prefix)

Description: The name prefix of the container instance

Type: `string`

Default: `null`

### <a name="input_container_instance_sensitive_environment_variables"></a> [container\_instance\_sensitive\_environment\_variables](#input\_container\_instance\_sensitive\_environment\_variables)

Description: List of additional sensitive environment variables to pass to the container.

Type:

```hcl
set(object({
    name  = string
    value = string
  }))
```

Default: `[]`

### <a name="input_container_instance_subnet_address_prefix"></a> [container\_instance\_subnet\_address\_prefix](#input\_container\_instance\_subnet\_address\_prefix)

Description: The address prefix for the Container App Environment. Either subnet\_id or subnet\_name and subnet\_address\_prefix must be specified.

Type: `string`

Default: `null`

### <a name="input_container_instance_subnet_cidr_size"></a> [container\_instance\_subnet\_cidr\_size](#input\_container\_instance\_subnet\_cidr\_size)

Description: The CIDR size for the container instance subnet.

Type: `number`

Default: `28`

### <a name="input_container_instance_subnet_id"></a> [container\_instance\_subnet\_id](#input\_container\_instance\_subnet\_id)

Description: The ID of a pre-existing subnet to use. Required if `virtual_network_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_container_instance_subnet_name"></a> [container\_instance\_subnet\_name](#input\_container\_instance\_subnet\_name)

Description: The name of the subnet. Must be specified if `virtual_network_creation_enabled == false`.

Type: `string`

Default: `null`

### <a name="input_container_registry_creation_enabled"></a> [container\_registry\_creation\_enabled](#input\_container\_registry\_creation\_enabled)

Description: Whether or not to create a container registry.

Type: `bool`

Default: `true`

### <a name="input_container_registry_dns_zone_id"></a> [container\_registry\_dns\_zone\_id](#input\_container\_registry\_dns\_zone\_id)

Description: The ID of the private DNS zone to create for the container registry. Only required if `container_registry_private_dns_zone_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_container_registry_name"></a> [container\_registry\_name](#input\_container\_registry\_name)

Description: The name of the container registry. Only required if `container_registry_creation_enabled` is `true`.

Type: `string`

Default: `null`

### <a name="input_container_registry_private_dns_zone_creation_enabled"></a> [container\_registry\_private\_dns\_zone\_creation\_enabled](#input\_container\_registry\_private\_dns\_zone\_creation\_enabled)

Description: Whether or not to create a private DNS zone for the container registry.

Type: `bool`

Default: `true`

### <a name="input_container_registry_private_endpoint_subnet_address_prefix"></a> [container\_registry\_private\_endpoint\_subnet\_address\_prefix](#input\_container\_registry\_private\_endpoint\_subnet\_address\_prefix)

Description: The address prefix for the Container App Environment. Either subnet\_id or subnet\_name and subnet\_address\_prefix must be specified.

Type: `string`

Default: `null`

### <a name="input_container_registry_private_endpoint_subnet_id"></a> [container\_registry\_private\_endpoint\_subnet\_id](#input\_container\_registry\_private\_endpoint\_subnet\_id)

Description: The ID of a pre-existing subnet to use. Required if `virtual_network_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_container_registry_private_endpoint_subnet_name"></a> [container\_registry\_private\_endpoint\_subnet\_name](#input\_container\_registry\_private\_endpoint\_subnet\_name)

Description: The name of the subnet. Must be specified if `virtual_network_creation_enabled == false`.

Type: `string`

Default: `null`

### <a name="input_container_registry_subnet_cidr_size"></a> [container\_registry\_subnet\_cidr\_size](#input\_container\_registry\_subnet\_cidr\_size)

Description: The CIDR size for the container registry subnet.

Type: `number`

Default: `29`

### <a name="input_custom_container_registry_images"></a> [custom\_container\_registry\_images](#input\_custom\_container\_registry\_images)

Description: The images to build and push to the container registry. This is only relevant if `container_registry_creation_enabled` is `true` and `use_default_container_image` is set to `false`.

- task\_name: The name of the task to create for building the image (e.g. `image-build-task`)
- dockerfile\_path: The path to the Dockerfile to use for building the image (e.g. `dockerfile`)
- context\_path: The path to the context of the Dockerfile in three sections `<repository-url>#<repository-commit>:<repository-folder-path>` (e.g. https://github.com/Azure/avm-container-images-cicd-agents-and-runners#bc4087f:azure-devops-agent)
- context\_access\_token: The access token to use for accessing the context. Supply a PAT if targetting a private repository.
- image\_names: A list of the names of the images to build (e.g. `["image-name:tag"]`)

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

Default: `null`

### <a name="input_custom_container_registry_login_server"></a> [custom\_container\_registry\_login\_server](#input\_custom\_container\_registry\_login\_server)

Description: The login server of the container registry to use if `container_registry_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_custom_container_registry_password"></a> [custom\_container\_registry\_password](#input\_custom\_container\_registry\_password)

Description: The password of the container registry to use if `container_registry_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_custom_container_registry_username"></a> [custom\_container\_registry\_username](#input\_custom\_container\_registry\_username)

Description: The username of the container registry to use if `container_registry_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_default_image_name"></a> [default\_image\_name](#input\_default\_image\_name)

Description: The default image name to use if no custom image is provided.

Type: `string`

Default: `null`

### <a name="input_default_image_registry_dockerfile_path"></a> [default\_image\_registry\_dockerfile\_path](#input\_default\_image\_registry\_dockerfile\_path)

Description: The default image registry Dockerfile path to use if no custom image is provided.

Type: `string`

Default: `"dockerfile"`

### <a name="input_default_image_repository_commit"></a> [default\_image\_repository\_commit](#input\_default\_image\_repository\_commit)

Description: The default image repository commit to use if no custom image is provided.

Type: `string`

Default: `"bc4087f"`

### <a name="input_default_image_repository_folder_paths"></a> [default\_image\_repository\_folder\_paths](#input\_default\_image\_repository\_folder\_paths)

Description: The default image repository folder path to use if no custom image is provided.

Type: `map(string)`

Default:

```json
{
  "azuredevops-container-app": "azure-devops-agent-aca",
  "azuredevops-container-instance": "azure-devops-agent-aci",
  "github-container-app": "github-runner-aca",
  "github-container-instance": "github-runner-aci"
}
```

### <a name="input_default_image_repository_url"></a> [default\_image\_repository\_url](#input\_default\_image\_repository\_url)

Description: The default image repository URL to use if no custom image is provided.

Type: `string`

Default: `"https://github.com/Azure/avm-container-images-cicd-agents-and-runners"`

### <a name="input_delays"></a> [delays](#input\_delays)

Description: Delays (in seconds) to apply to the module operations.

Type:

```hcl
object({
    delay_after_container_image_build = number
  })
```

Default:

```json
{
  "delay_after_container_image_build": 30
}
```

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_lock"></a> [lock](#input\_lock)

Description:   Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_log_analytics_workspace_creation_enabled"></a> [log\_analytics\_workspace\_creation\_enabled](#input\_log\_analytics\_workspace\_creation\_enabled)

Description: Whether or not to create a log analytics workspace.

Type: `bool`

Default: `true`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: The resource Id of the Log Analytics Workspace.

Type: `string`

Default: `null`

### <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name)

Description: The name of the log analytics workspace. Only required if `log_analytics_workspace_creation_enabled == false`.

Type: `string`

Default: `null`

### <a name="input_log_analytics_workspace_retention_in_days"></a> [log\_analytics\_workspace\_retention\_in\_days](#input\_log\_analytics\_workspace\_retention\_in\_days)

Description: The retention period for the Log Analytics Workspace.

Type: `number`

Default: `30`

### <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku)

Description: The SKU of the Log Analytics Workspace.

Type: `string`

Default: `"PerGB2018"`

### <a name="input_nat_gateway_creation_enabled"></a> [nat\_gateway\_creation\_enabled](#input\_nat\_gateway\_creation\_enabled)

Description: Whether or not to create a NAT Gateway.

Type: `bool`

Default: `true`

### <a name="input_nat_gateway_id"></a> [nat\_gateway\_id](#input\_nat\_gateway\_id)

Description: The ID of the NAT Gateway. Only required if `nat_gateway_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_nat_gateway_name"></a> [nat\_gateway\_name](#input\_nat\_gateway\_name)

Description: The name of the NAT Gateway.

Type: `string`

Default: `null`

### <a name="input_public_ip_creation_enabled"></a> [public\_ip\_creation\_enabled](#input\_public\_ip\_creation\_enabled)

Description: Whether or not to create a public IP.

Type: `bool`

Default: `true`

### <a name="input_public_ip_id"></a> [public\_ip\_id](#input\_public\_ip\_id)

Description: The ID of the public IP. Only required if `public_ip_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_public_ip_name"></a> [public\_ip\_name](#input\_public\_ip\_name)

Description: The name of the public IP.

Type: `string`

Default: `null`

### <a name="input_resource_group_creation_enabled"></a> [resource\_group\_creation\_enabled](#input\_resource\_group\_creation\_enabled)

Description: Whether or not to create a resource group.

Type: `bool`

Default: `true`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed. Must be specified if `resource_group_creation_enabled == false`

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_use_default_container_image"></a> [use\_default\_container\_image](#input\_use\_default\_container\_image)

Description: Whether or not to use the default container image provided by the module.

Type: `bool`

Default: `true`

### <a name="input_use_private_networking"></a> [use\_private\_networking](#input\_use\_private\_networking)

Description: Whether or not to use private networking for the container registry.

Type: `bool`

Default: `true`

### <a name="input_user_assigned_managed_identity_creation_enabled"></a> [user\_assigned\_managed\_identity\_creation\_enabled](#input\_user\_assigned\_managed\_identity\_creation\_enabled)

Description: Whether or not to create a user assigned managed identity.

Type: `bool`

Default: `true`

### <a name="input_user_assigned_managed_identity_id"></a> [user\_assigned\_managed\_identity\_id](#input\_user\_assigned\_managed\_identity\_id)

Description: The resource Id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false`.

Type: `string`

Default: `null`

### <a name="input_user_assigned_managed_identity_name"></a> [user\_assigned\_managed\_identity\_name](#input\_user\_assigned\_managed\_identity\_name)

Description: The name of the user assigned managed identity. Must be specified if `user_assigned_managed_identity_creation_enabled == true`.

Type: `string`

Default: `null`

### <a name="input_user_assigned_managed_identity_principal_id"></a> [user\_assigned\_managed\_identity\_principal\_id](#input\_user\_assigned\_managed\_identity\_principal\_id)

Description: The principal id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false`.

Type: `string`

Default: `null`

### <a name="input_version_control_system_agent_name_prefix"></a> [version\_control\_system\_agent\_name\_prefix](#input\_version\_control\_system\_agent\_name\_prefix)

Description: The version control system agent name prefix.

Type: `string`

Default: `null`

### <a name="input_version_control_system_agent_target_queue_length"></a> [version\_control\_system\_agent\_target\_queue\_length](#input\_version\_control\_system\_agent\_target\_queue\_length)

Description: The target value for the amound of pending jobs to scale on.

Type: `number`

Default: `1`

### <a name="input_version_control_system_enterprise"></a> [version\_control\_system\_enterprise](#input\_version\_control\_system\_enterprise)

Description: The enterprise name for the version control system.

Type: `string`

Default: `null`

### <a name="input_version_control_system_placeholder_agent_name"></a> [version\_control\_system\_placeholder\_agent\_name](#input\_version\_control\_system\_placeholder\_agent\_name)

Description: The version control system placeholder agent name.

Type: `string`

Default: `null`

### <a name="input_version_control_system_pool_name"></a> [version\_control\_system\_pool\_name](#input\_version\_control\_system\_pool\_name)

Description: The name of the agent pool in the version control system.

Type: `string`

Default: `null`

### <a name="input_version_control_system_repository"></a> [version\_control\_system\_repository](#input\_version\_control\_system\_repository)

Description: The version control system repository to deploy the agents too.

Type: `string`

Default: `null`

### <a name="input_version_control_system_runner_group"></a> [version\_control\_system\_runner\_group](#input\_version\_control\_system\_runner\_group)

Description: The runner group to add the runner to.

Type: `string`

Default: `null`

### <a name="input_version_control_system_runner_scope"></a> [version\_control\_system\_runner\_scope](#input\_version\_control\_system\_runner\_scope)

Description: The scope of the runner. Must be `ent`, `org`, or `repo`. This is ignored for Azure DevOps.

Type: `string`

Default: `"repo"`

### <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space)

Description: The address space for the virtual network. Must be specified if `virtual_network_creation_enabled` is `true`.

Type: `string`

Default: `null`

### <a name="input_virtual_network_creation_enabled"></a> [virtual\_network\_creation\_enabled](#input\_virtual\_network\_creation\_enabled)

Description: Whether or not to create a virtual network.

Type: `bool`

Default: `true`

### <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id)

Description: The ID of the virtual network. Only required if `virtual_network_creation_enabled` is `false`.

Type: `string`

Default: `null`

### <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name)

Description: The name of the virtual network. Must be specified if `virtual_network_creation_enabled` is `true`.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_container_app_subnet_resource_id"></a> [container\_app\_subnet\_resource\_id](#output\_container\_app\_subnet\_resource\_id)

Description: The subnet id of the container app job.

### <a name="output_container_instance_names"></a> [container\_instance\_names](#output\_container\_instance\_names)

Description: The names of the container instances.

### <a name="output_container_instance_resource_ids"></a> [container\_instance\_resource\_ids](#output\_container\_instance\_resource\_ids)

Description: The resource ids of the container instances.

### <a name="output_container_registry_login_server"></a> [container\_registry\_login\_server](#output\_container\_registry\_login\_server)

Description: The container registry login server.

### <a name="output_container_registry_name"></a> [container\_registry\_name](#output\_container\_registry\_name)

Description: The container registry name.

### <a name="output_container_registry_resource_id"></a> [container\_registry\_resource\_id](#output\_container\_registry\_resource\_id)

Description: The container registry resource id.

### <a name="output_job_name"></a> [job\_name](#output\_job\_name)

Description: The name of the container app job.

### <a name="output_job_resource_id"></a> [job\_resource\_id](#output\_job\_resource\_id)

Description: The resource id of the container app job.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the container app environment.

### <a name="output_placeholder_job_name"></a> [placeholder\_job\_name](#output\_placeholder\_job\_name)

Description: The name of the placeholder contaienr app job.

### <a name="output_placeholder_job_resource_id"></a> [placeholder\_job\_resource\_id](#output\_placeholder\_job\_resource\_id)

Description: The resource id of the placeholder container app job.

### <a name="output_private_dns_zone_subnet_resource_id"></a> [private\_dns\_zone\_subnet\_resource\_id](#output\_private\_dns\_zone\_subnet\_resource\_id)

Description: The private dns zone id of the container registry.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource id of the container app environment.

### <a name="output_user_assigned_managed_identity_id"></a> [user\_assigned\_managed\_identity\_id](#output\_user\_assigned\_managed\_identity\_id)

Description: The resource id of the user assigned managed identity.

### <a name="output_user_assigned_managed_identity_principal_id"></a> [user\_assigned\_managed\_identity\_principal\_id](#output\_user\_assigned\_managed\_identity\_principal\_id)

Description: The principal id of the user assigned managed identity.

### <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name)

Description: The virtual network name.

### <a name="output_virtual_network_resource_id"></a> [virtual\_network\_resource\_id](#output\_virtual\_network\_resource\_id)

Description: The virtual network resource id.

## Modules

The following Modules are called:

### <a name="module_container_app_job"></a> [container\_app\_job](#module\_container\_app\_job)

Source: ./modules/container-app-job

Version:

### <a name="module_container_instance"></a> [container\_instance](#module\_container\_instance)

Source: ./modules/container-instance

Version:

### <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry)

Source: ./modules/container-registry

Version:

### <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace)

Source: Azure/avm-res-operationalinsights-workspace/azurerm

Version: 0.3.3

### <a name="module_user_assigned_managed_identity"></a> [user\_assigned\_managed\_identity](#module\_user\_assigned\_managed\_identity)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: 0.3.1

### <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.7.1

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->