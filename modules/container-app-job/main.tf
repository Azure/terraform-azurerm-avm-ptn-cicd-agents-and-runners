resource "azapi_resource" "job" {
  location  = var.location
  name      = local.job_name
  parent_id = var.resource_group_id
  type      = "Microsoft.App/jobs@2023-05-01"
  body = {
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
  }
  tags = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }
}

resource "azapi_resource" "placeholder" {
  count = var.placeholder_job_creation_enabled ? 1 : 0

  location  = var.location
  name      = local.placeholder_job_name
  parent_id = var.resource_group_id
  type      = "Microsoft.App/jobs@2023-05-01"
  body = {
    properties = {
      environmentId = var.container_app_environment_id
      configuration = {
        replicaRetryLimit = var.placeholder_replica_retry_limit
        replicaTimeout    = var.placeholder_replica_timeout
        registries        = local.container_registies
        manualTriggerConfig = {
          parallelism            = 1
          replicaCompletionCount = 1
        }
        secrets     = local.secrets
        triggerType = "Manual"
      }
      template = {
        containers = [local.container_placeholder]
      }
    }
  }
  tags = null

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_managed_identity_id]
  }
}

resource "azapi_resource_action" "placeholder_trigger" {
  count = var.placeholder_job_creation_enabled ? 1 : 0

  action      = "start"
  resource_id = azapi_resource.placeholder[0].id
  type        = "Microsoft.App/jobs@2024-03-01"
  body        = {}

  lifecycle {
    replace_triggered_by = [azapi_resource.placeholder]
  }
}
