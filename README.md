<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-ptn-cicd-agents-and-runners

This module is designed to deploy self-hosted Azure DevOps and Github runners.

## Features

- Container App Environments:
  - Github Runners
  - Azure DevOps Agents

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.9.0, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

- <a name="provider_random"></a> [random](#provider\_random)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this_laws](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_subnet.this_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.this_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
- [azurerm_virtual_network.this_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_container_image_name"></a> [container\_image\_name](#input\_container\_image\_name)

Description: Fully qualified name of the Docker image the agents should run.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Prefix used for naming the container app environment and container app jobs.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_azp_pool_name"></a> [azp\_pool\_name](#input\_azp\_pool\_name)

Description: Name of the pool that agents should register against in Azure DevOps.

Type: `string`

Default: `null`

### <a name="input_azp_url"></a> [azp\_url](#input\_azp\_url)

Description: URL for the Azure DevOps project.

Type: `string`

Default: `null`

### <a name="input_azure_container_registries"></a> [azure\_container\_registries](#input\_azure\_container\_registries)

Description: A list of Azure Container Registries to link to the container app environment. Required values are:
- `login_server` - The login server url for the Azure Container Registry.
- `identity` - The id of the identity used to authenticate to the registry. For system managed identity, use 'System'.

Type:

```hcl
set(object({
    login_server = string
    identity     = string
  }))
```

Default: `null`

### <a name="input_cicd_system"></a> [cicd\_system](#input\_cicd\_system)

Description: The name of the CI/CD system to deploy the agents too. Allowed values are 'AzureDevOps' or 'Github'

Type: `string`

Default: `false`

### <a name="input_container_app_environment_name"></a> [container\_app\_environment\_name](#input\_container\_app\_environment\_name)

Description: The name of the Container App Environment.

Type: `string`

Default: `null`

### <a name="input_container_app_job_placeholder_name"></a> [container\_app\_job\_placeholder\_name](#input\_container\_app\_job\_placeholder\_name)

Description: The name of the Container App placeholder job.

Type: `string`

Default: `null`

### <a name="input_container_app_job_runner_name"></a> [container\_app\_job\_runner\_name](#input\_container\_app\_job\_runner\_name)

Description: The name of the Container App runner job.

Type: `string`

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: List of environment variables to pass to the container.

Type:

```hcl
set(object({
    name  = string
    value = string
  }))
```

Default: `null`

### <a name="input_github_keda_metadata"></a> [github\_keda\_metadata](#input\_github\_keda\_metadata)

Description: Metadata for the Keda Github Runner Scaler  
https://keda.sh/docs/2.13/scalers/github-runner/

Type:

```hcl
object({
    githubAPIURL              = optional(string, "https://api.github.com")
    owner                     = string
    runnerScope               = string
    repos                     = optional(string)
    labels                    = optional(set(string))
    targetWorkflowQueueLength = optional(string, "1")
    applicationID             = optional(string)
    installationID            = optional(string)
  })
```

Default: `null`

### <a name="input_key_vault_user_assigned_identity"></a> [key\_vault\_user\_assigned\_identity](#input\_key\_vault\_user\_assigned\_identity)

Description: The user assigned identity to use to authenticate with Key Vault.  
Must be specified if multiple user assigned are specified in `managed_identities`.

Type: `string`

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed. Must be specified if `resource_group_creation_enabled == true`.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

Default: `{}`

### <a name="input_log_analytics_workspace_creation_enabled"></a> [log\_analytics\_workspace\_creation\_enabled](#input\_log\_analytics\_workspace\_creation\_enabled)

Description: Whether or not to create a log analytics workspace for the Container App Environment.

Type: `bool`

Default: `true`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: Terraform Id of the Log Analytics Workspace to connect to the Container App Environment.

Type: `string`

Default: `null`

### <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name)

Description: The name to give the deployed log analytics workspace.

Type: `string`

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Managed identities to be created for the resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_max_execution_count"></a> [max\_execution\_count](#input\_max\_execution\_count)

Description: The maximum number of executions (ADO jobs) to spawn per polling interval.

Type: `number`

Default: `100`

### <a name="input_min_execution_count"></a> [min\_execution\_count](#input\_min\_execution\_count)

Description: The minimum number of executions (ADO jobs) to spawn per polling interval.

Type: `number`

Default: `0`

### <a name="input_pat_env_var_name"></a> [pat\_env\_var\_name](#input\_pat\_env\_var\_name)

Description: Name of the PAT token environment variable.  
Defaults to 'AZP\_TOKEN' when 'cicd\_system' == 'AzureDevOps'  
Defaults to 'GH\_RUNNER\_TOKEN' when 'cicd\_system' == 'Github'

Type: `string`

Default: `null`

### <a name="input_pat_token_secret_url"></a> [pat\_token\_secret\_url](#input\_pat\_token\_secret\_url)

Description: The value of the personal access token the agents will use for authenticating to Azure DevOps.  
One of 'pat\_token\_value' or 'pat\_token\_secret\_url' must be specified.

Type: `string`

Default: `null`

### <a name="input_pat_token_value"></a> [pat\_token\_value](#input\_pat\_token\_value)

Description: The value of the personal access token the agents will use for authenticating to Azure DevOps.  
One of 'pat\_token\_value' or 'pat\_token\_secret\_url' must be specified.

Type: `string`

Default: `null`

### <a name="input_placeholder_agent_name"></a> [placeholder\_agent\_name](#input\_placeholder\_agent\_name)

Description: The name of the agent that will appear in Azure DevOps for the placeholder agent.

Type: `string`

Default: `"placeholder-agent"`

### <a name="input_placeholder_container_name"></a> [placeholder\_container\_name](#input\_placeholder\_container\_name)

Description: The name of the container for the placeholder Container Apps job.

Type: `string`

Default: `"ado-agent-linux"`

### <a name="input_placeholder_replica_retry_limit"></a> [placeholder\_replica\_retry\_limit](#input\_placeholder\_replica\_retry\_limit)

Description: The number of times to retry the placeholder Container Apps job.

Type: `number`

Default: `0`

### <a name="input_placeholder_replica_timeout"></a> [placeholder\_replica\_timeout](#input\_placeholder\_replica\_timeout)

Description: The timeout in seconds for the placeholder Container Apps job.

Type: `number`

Default: `300`

### <a name="input_polling_interval_seconds"></a> [polling\_interval\_seconds](#input\_polling\_interval\_seconds)

Description: How often should the pipeline queue be checked for new events, in seconds.

Type: `number`

Default: `30`

### <a name="input_resource_group_creation_enabled"></a> [resource\_group\_creation\_enabled](#input\_resource\_group\_creation\_enabled)

Description: Whether or not to create a resource group.

Type: `bool`

Default: `true`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed. Must be specified if `resource_group_creation_enabled == false`

Type: `string`

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_runner_agent_cpu"></a> [runner\_agent\_cpu](#input\_runner\_agent\_cpu)

Description: Required CPU in cores, e.g. 0.5

Type: `number`

Default: `1`

### <a name="input_runner_agent_memory"></a> [runner\_agent\_memory](#input\_runner\_agent\_memory)

Description: Required memory, e.g. '250Mb'

Type: `string`

Default: `"2Gi"`

### <a name="input_runner_container_name"></a> [runner\_container\_name](#input\_runner\_container\_name)

Description: The name of the container for the runner Container Apps job.

Type: `string`

Default: `"ado-agent-linux"`

### <a name="input_runner_replica_retry_limit"></a> [runner\_replica\_retry\_limit](#input\_runner\_replica\_retry\_limit)

Description: The number of times to retry the runner Container Apps job.

Type: `number`

Default: `3`

### <a name="input_runner_replica_timeout"></a> [runner\_replica\_timeout](#input\_runner\_replica\_timeout)

Description: The timeout in seconds for the runner Container Apps job.

Type: `number`

Default: `1800`

### <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix)

Description: The address prefix for the Container App Environment. Either subnet\_id or subnet\_name and subnet\_address\_prefix must be specified.

Type: `string`

Default: `""`

### <a name="input_subnet_creation_enabled"></a> [subnet\_creation\_enabled](#input\_subnet\_creation\_enabled)

Description: Whether or not to create a subnet for the Container App Environment.

Type: `bool`

Default: `true`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of a pre-existing subnet to use for the Container App Environment. Either subnet\_id or subnet\_name and subnet\_address\_prefix must be specified.

Type: `string`

Default: `""`

### <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name)

Description: The subnet name for the Container App Environment. Either subnet\_id or subnet\_name and subnet\_address\_prefix must be specified.

Type: `string`

Default: `""`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: The map of tags to be applied to the resource

Type: `map(any)`

Default: `{}`

### <a name="input_target_queue_length"></a> [target\_queue\_length](#input\_target\_queue\_length)

Description: The target value for the amound of pending jobs to scale on.

Type: `number`

Default: `1`

### <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled)

Description: Whether enable tracing tags that generated by BridgeCrew Yor.

Type: `bool`

Default: `false`

### <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix)

Description: Default prefix for generated tracing tags

Type: `string`

Default: `"avm_"`

### <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space)

Description: The address range for the Container App Environment virtual network. Either virtual\_network\_id or virtual\_network\_name and virtual\_network\_address\_range must be specified.

Type: `string`

Default: `""`

### <a name="input_virtual_network_creation_enabled"></a> [virtual\_network\_creation\_enabled](#input\_virtual\_network\_creation\_enabled)

Description: Whether or not to create a virtual network for the Container App Environment.

Type: `bool`

Default: `true`

### <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id)

Description: The ID of a pre-existing virtual network to use for the Container App Environment. Either virtual\_network\_id or virtual\_network\_name and virtual\_network\_address\_range must be specified.

Type: `string`

Default: `""`

### <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name)

Description: The virtual network name for the Container App Environment. Either virtual\_network\_id or virtual\_network\_name and virtual\_network\_address\_range must be specified.

Type: `string`

Default: `""`

### <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name)

Description: The name of the Virtual Network's Resource Group. Must be specified if `virtual_network_creation_enabled` == `false`

Type: `string`

Default: `""`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The container app environment.

### <a name="output_resource_placeholder_job"></a> [resource\_placeholder\_job](#output\_resource\_placeholder\_job)

Description: The placeholder job.

### <a name="output_resource_runner_job"></a> [resource\_runner\_job](#output\_resource\_runner\_job)

Description: The runner job.

## Modules

The following Modules are called:

### <a name="module_ca_ado"></a> [ca\_ado](#module\_ca\_ado)

Source: ./modules/ca-azure-devops-agents

Version:

### <a name="module_ca_github"></a> [ca\_github](#module\_ca\_github)

Source: ./modules/ca-github-runners

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->