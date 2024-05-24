<!-- BEGIN_TF_DOCS -->
# ca-github-runners

This submodule deploys an Azure Container App Environment, and job, as a Github runner.

```hcl
# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_container_app_environment.this_ca_environment.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_container_app_environment.this_ca_environment.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

# resources
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_container_app_environment" "this_ca_environment" {
  location                       = data.azurerm_resource_group.rg.location
  name                           = coalesce(var.container_app_environment_name, "cae-${var.name}")
  resource_group_name            = data.azurerm_resource_group.rg.name
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = true
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  tags = (/*<box>*/ (var.tracing_tags_enabled ? { for k, v in /*</box>*/ {
    avm_git_commit           = "f2507b14218314d1fc8ce045727dcec2a1a80398"
    avm_git_file             = "main.tf"
    avm_git_last_modified_at = "2024-04-03 13:55:59"
    avm_git_org              = "BlakeWills"
    avm_git_repo             = "terraform-azurerm-avm-ptn-cicd-agents-and-runners-ca"
    avm_yor_name             = "this_ca_environment"
    avm_yor_trace            = "e81b70e5-cfe9-4918-9685-57bc900c0d68"
  } /*<box>*/ : replace(k, "avm_", var.tracing_tags_prefix) => v } : {}) /*</box>*/)
  zone_redundancy_enabled = true
}
# todo: remove non-sensitive
resource "azapi_resource" "runner_job" {
  type = "Microsoft.App/jobs@2023-05-01"
  body = nonsensitive(jsonencode({
    properties = {
      environmentId = azurerm_container_app_environment.this_ca_environment.id
      configuration = {
        replicaRetryLimit = var.runner_replica_retry_limit
        replicaTimeout    = var.runner_replica_timeout
        registries        = var.azure_container_registries
        eventTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
          scale = {
            minExecutions   = var.min_execution_count
            maxExecutions   = var.max_execution_count
            pollingInterval = var.polling_interval_seconds
            rules = [{
              name     = "github-runner"
              type     = "github-runner"
              metadata = var.github_keda_metadata
              auth = [
                {
                  secretRef        = "personal-access-token",
                  triggerParameter = "personalAccessToken"
                }
              ]
            }]
          }
        }
        secrets = [
          {
            name        = "personal-access-token"
            value       = var.pat_token_value
            identity    = var.pat_token_value != null ? null : local.key_vault_user_assigned_identity
            keyVaultUrl = var.pat_token_value != null ? null : var.pat_token_secret_url
          }
        ]
        triggerType = "Event"
      }
      template = {
        containers = [{
          name  = var.runner_container_name
          image = var.container_image_name
          resources = {
            cpu    = var.runner_agent_cpu
            memory = var.runner_agent_memory
          }
          env = concat(tolist(var.environment_variables), tolist([
            {
              name      = var.pat_env_var_name
              secretRef = "personal-access-token"
            }
          ]))
        }]
      }
    }
  }))
  location  = data.azurerm_resource_group.rg.location
  name      = coalesce(var.container_app_job_runner_name, "ca-runner-${var.name}")
  parent_id = data.azurerm_resource_group.rg.id
  tags      = null

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned
    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  lifecycle {
    replace_triggered_by = [azurerm_container_app_environment.this_ca_environment]

    precondition {
      condition     = var.pat_token_secret_url == null || local.key_vault_user_assigned_identity != null
      error_message = "Unable to determine identity for authenticating to Azure Key Vault. Either specify `key_vault_user_assigned_identity` or configure a single identity."
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.9.0, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (>= 1.9.0, < 2.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

## Resources

The following resources are used by this module:

- [azapi_resource.runner_job](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_container_app_environment.this_ca_environment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

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

### <a name="input_container_app_environment_name"></a> [container\_app\_environment\_name](#input\_container\_app\_environment\_name)

Description: The name of the Container App Environment.

Type: `string`

### <a name="input_container_app_job_runner_name"></a> [container\_app\_job\_runner\_name](#input\_container\_app\_job\_runner\_name)

Description: The name of the Container App runner job.

Type: `string`

### <a name="input_container_image_name"></a> [container\_image\_name](#input\_container\_image\_name)

Description: Fully qualified name of the Docker image the agents should run.

Type: `string`

### <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables)

Description: List of environment variables to pass to the container.

Type:

```hcl
set(object({
    name  = string
    value = string
  }))
```

### <a name="input_github_keda_metadata"></a> [github\_keda\_metadata](#input\_github\_keda\_metadata)

Description: n/a

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

### <a name="input_key_vault_user_assigned_identity"></a> [key\_vault\_user\_assigned\_identity](#input\_key\_vault\_user\_assigned\_identity)

Description: The user assigned identity to use to authenticate with Key Vault.  
Must be specified if multiple user assigned are specified in `managed_identities`.

Type: `string`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: The id of the log analytics workspace to connect the container app agents to.

Type: `string`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Managed identities to be created for the resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

### <a name="input_max_execution_count"></a> [max\_execution\_count](#input\_max\_execution\_count)

Description: The maximum number of executions (ADO jobs) to spawn per polling interval.

Type: `number`

### <a name="input_min_execution_count"></a> [min\_execution\_count](#input\_min\_execution\_count)

Description: The minimum number of executions (ADO jobs) to spawn per polling interval.

Type: `number`

### <a name="input_name"></a> [name](#input\_name)

Description: Prefix used for naming the container app environment and container app jobs.

Type: `string`

### <a name="input_pat_token_secret_url"></a> [pat\_token\_secret\_url](#input\_pat\_token\_secret\_url)

Description: The value of the personal access token the agents will use for authenticating to Azure DevOps.  
One of 'pat\_token\_value' or 'pat\_token\_secret\_url' must be specified.

Type: `string`

### <a name="input_pat_token_value"></a> [pat\_token\_value](#input\_pat\_token\_value)

Description: The value of the personal access token the agents will use for authenticating to Azure DevOps.  
One of 'pat\_token\_value' or 'pat\_token\_secret\_url' must be specified.

Type: `string`

### <a name="input_polling_interval_seconds"></a> [polling\_interval\_seconds](#input\_polling\_interval\_seconds)

Description: How often should the pipeline queue be checked for new events, in seconds.

Type: `number`

### <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location)

Description: The location of the resource group where the resources will be deployed.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group where the resources will be deployed.

Type: `string`

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

### <a name="input_runner_agent_cpu"></a> [runner\_agent\_cpu](#input\_runner\_agent\_cpu)

Description: Required CPU in cores, e.g. 0.5

Type: `number`

### <a name="input_runner_agent_memory"></a> [runner\_agent\_memory](#input\_runner\_agent\_memory)

Description: Required memory, e.g. '250Mb'

Type: `string`

### <a name="input_runner_container_name"></a> [runner\_container\_name](#input\_runner\_container\_name)

Description: The name of the container for the runner Container Apps job.

Type: `string`

### <a name="input_runner_replica_retry_limit"></a> [runner\_replica\_retry\_limit](#input\_runner\_replica\_retry\_limit)

Description: The number of times to retry the runner Container Apps job.

Type: `number`

### <a name="input_runner_replica_timeout"></a> [runner\_replica\_timeout](#input\_runner\_replica\_timeout)

Description: The timeout in seconds for the runner Container Apps job.

Type: `number`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The subnet id to use for the Container App Environment.

Type: `string`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: The map of tags to be applied to the resource

Type: `map(any)`

### <a name="input_target_queue_length"></a> [target\_queue\_length](#input\_target\_queue\_length)

Description: The target value for the amound of pending jobs to scale on.

Type: `number`

### <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled)

Description: Whether enable tracing tags that generated by BridgeCrew Yor.

Type: `bool`

### <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix)

Description: Default prefix for generated tracing tags

Type: `string`

### <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id)

Description: The id of the virtual network to use for the Container App Environment.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_pat_env_var_name"></a> [pat\_env\_var\_name](#input\_pat\_env\_var\_name)

Description: Name of the PAT token environment variable. Defaults to 'GH\_RUNNER\_TOKEN'.

Type: `string`

Default: `"GH_RUNNER_TOKEN"`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The container app environment.

### <a name="output_resource_runner_job"></a> [resource\_runner\_job](#output\_resource\_runner\_job)

Description: The runner job.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->