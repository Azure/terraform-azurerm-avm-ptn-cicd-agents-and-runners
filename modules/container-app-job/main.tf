resource "azapi_resource" "job" {
  type = "Microsoft.App/jobs@2023-05-01"
  body = nonsensitive(jsonencode({
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
  }))
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
  count = var.create_placeholder_job ? 1 : 0

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
