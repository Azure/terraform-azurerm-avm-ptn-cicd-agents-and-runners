<!-- BEGIN_TF_DOCS -->
# CI/CD Agents and Runners - Container Apps Job

This submodule deploys an Azure Container Apps Job for CI/CD agents and runners.

```hcl
resource "azapi_resource" "job" {
  type = "Microsoft.App/jobs@2023-05-01"
  body = jsonencode({
    properties = {
      environmentId = var.container_app_environment_id
      configuration = {
        replicaRetryLimit = var.replica_retry_limit
        replicaTimeout    = var.replica_timeout
        registries        = local.container_registies
        eventTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
          scale = {
            minExecutions   = var.min_execution_count
            maxExecutions   = var.max_execution_count
            pollingInterval = var.polling_interval_seconds
            rules           = [local.keda_rule]
          }
        }
        secrets     = local.secrets
        triggerType = "Event"
      }
      template = {
        containers = [local.container_job]
      }
    }
  })
  location  = var.location
  name      = local.job_name
  parent_id = var.resource_group_id
  tags      = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }
}

resource "azapi_resource" "placeholder" {
  count = var.placeholder_job_creation_enabled ? 1 : 0

  type = "Microsoft.App/jobs@2023-05-01"
  body = jsonencode({
    properties = {
      environmentId = var.container_app_environment_id
      configuration = {
        replicaRetryLimit = var.placeholder_replica_retry_limit
        replicaTimeout    = var.placeholder_replica_timeout
        registries        = local.container_registies
        scheduleTriggerConfig = {
          cronExpression         = var.placeholder_cron_expression
          parallelism            = 1
          replicaCompletionCount = 1
        }
        secrets     = local.secrets
        triggerType = "Schedule"
      }
      template = {
        containers = [local.container_placeholder]
      }
    }
  })
  location  = var.location
  name      = local.placeholder_job_name
  parent_id = var.resource_group_id
  tags      = null

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~> 1.14)

## Resources

The following resources are used by this module:

- [azapi_resource.job](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.placeholder](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id)

Description: The resource id of the Container App Environment.

Type: `string`

### <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu)

Description: Required CPU in cores, e.g. 0.5

Type: `number`

### <a name="input_container_image_name"></a> [container\_image\_name](#input\_container\_image\_name)

Description: Fully qualified name of the Docker image the agents should run.

Type: `string`

### <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory)

Description: Required memory, e.g. '250Mb'

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

### <a name="input_job_container_name"></a> [job\_container\_name](#input\_job\_container\_name)

Description: The name of the container for the runner Container Apps job.

Type: `string`

### <a name="input_job_name"></a> [job\_name](#input\_job\_name)

Description: The name of the Container App job.

Type: `string`

### <a name="input_keda_meta_data"></a> [keda\_meta\_data](#input\_keda\_meta\_data)

Description: The metadata for the KEDA scaler.

Type: `map(string)`

### <a name="input_keda_rule_type"></a> [keda\_rule\_type](#input\_keda\_rule\_type)

Description: The type of the KEDA rule.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_max_execution_count"></a> [max\_execution\_count](#input\_max\_execution\_count)

Description: The maximum number of executions to spawn per polling interval.

Type: `number`

### <a name="input_min_execution_count"></a> [min\_execution\_count](#input\_min\_execution\_count)

Description: The minimum number of executions to spawn per polling interval.

Type: `number`

### <a name="input_polling_interval_seconds"></a> [polling\_interval\_seconds](#input\_polling\_interval\_seconds)

Description: How often should the pipeline queue be checked for new events, in seconds.

Type: `number`

### <a name="input_postfix"></a> [postfix](#input\_postfix)

Description: Postfix used for naming the resources where the name isn't supplied.

Type: `string`

### <a name="input_registry_login_server"></a> [registry\_login\_server](#input\_registry\_login\_server)

Description: The login server of the container registry.

Type: `string`

### <a name="input_replica_retry_limit"></a> [replica\_retry\_limit](#input\_replica\_retry\_limit)

Description: The number of times to retry the runner Container Apps job.

Type: `number`

### <a name="input_replica_timeout"></a> [replica\_timeout](#input\_replica\_timeout)

Description: The timeout in seconds for the runner Container Apps job.

Type: `number`

### <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id)

Description: The id of the resource group where the resources will be deployed.

Type: `string`

### <a name="input_sensitive_environment_variables"></a> [sensitive\_environment\_variables](#input\_sensitive\_environment\_variables)

Description: List of sensitive environment variables to pass to the container.

Type:

```hcl
set(object({
    name                      = string
    value                     = string
    container_app_secret_name = string
    keda_auth_name            = optional(string)
  }))
```

### <a name="input_user_assigned_managed_identity_id"></a> [user\_assigned\_managed\_identity\_id](#input\_user\_assigned\_managed\_identity\_id)

Description: The resource Id of the user assigned managed identity.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_environment_variables_placeholder"></a> [environment\_variables\_placeholder](#input\_environment\_variables\_placeholder)

Description: List of environment variables to pass only to the placeholder container.

Type:

```hcl
set(object({
    name  = string
    value = string
  }))
```

Default: `[]`

### <a name="input_placeholder_container_name"></a> [placeholder\_container\_name](#input\_placeholder\_container\_name)

Description: The name of the container for the placeholder Container Apps job.

Type: `string`

Default: `null`

### <a name="input_placeholder_cron_expression"></a> [placeholder\_cron\_expression](#input\_placeholder\_cron\_expression)

Description: The cron expression for the placeholder Container Apps job.

Type: `string`

Default: `null`

### <a name="input_placeholder_job_creation_enabled"></a> [placeholder\_job\_creation\_enabled](#input\_placeholder\_job\_creation\_enabled)

Description: Whether or not to create a placeholder job.

Type: `bool`

Default: `false`

### <a name="input_placeholder_job_name"></a> [placeholder\_job\_name](#input\_placeholder\_job\_name)

Description: The name of the Container App placeholder job.

Type: `string`

Default: `null`

### <a name="input_placeholder_replica_retry_limit"></a> [placeholder\_replica\_retry\_limit](#input\_placeholder\_replica\_retry\_limit)

Description: The number of times to retry the placeholder Container Apps job.

Type: `number`

Default: `3`

### <a name="input_placeholder_replica_timeout"></a> [placeholder\_replica\_timeout](#input\_placeholder\_replica\_timeout)

Description: The timeout in seconds for the placeholder Container Apps job.

Type: `number`

Default: `300`

### <a name="input_registry_password"></a> [registry\_password](#input\_registry\_password)

Description: Password of the container registry.

Type: `string`

Default: `null`

### <a name="input_registry_username"></a> [registry\_username](#input\_registry\_username)

Description: Name of the container registry.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the container app job.

### <a name="output_placeholder_job_name"></a> [placeholder\_job\_name](#output\_placeholder\_job\_name)

Description: The name of the placeholder job.

### <a name="output_placeholder_job_resource"></a> [placeholder\_job\_resource](#output\_placeholder\_job\_resource)

Description: The placeholder job resource.

### <a name="output_placeholder_job_resource_id"></a> [placeholder\_job\_resource\_id](#output\_placeholder\_job\_resource\_id)

Description: The resource id of the placeholder job.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource id of the container app job.

### <a name="output_runner_job_resource"></a> [runner\_job\_resource](#output\_runner\_job\_resource)

Description: The job resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->