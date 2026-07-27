module "webhook_storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.7.0"
  count   = var.webhook_scaling_enabled ? 1 : 0

  location                        = var.location
  name                            = local.webhook_storage_account_name
  parent_id                       = local.resource_group_id
  account_kind                    = "StorageV2"
  account_replication_type        = var.use_zone_redundancy ? "ZRS" : "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  enable_telemetry                = var.enable_telemetry
  min_tls_version                 = "TLS1_2"
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
  private_endpoints = {
    queue = {
      name                          = "pe-${local.webhook_storage_account_name}-queue"
      subnet_resource_id            = coalesce(var.webhook_storage_private_endpoint_subnet_id, local.container_registry_private_endpoint_subnet_id)
      subresource_name              = "queue"
      private_dns_zone_resource_ids = var.webhook_storage_queue_dns_zone_id == null ? [] : [var.webhook_storage_queue_dns_zone_id]
      tags                          = var.tags
    }
  }
  public_network_access_enabled = false
  queues = {
    runner_jobs = {
      name = var.webhook_queue_name
    }
  }
  # Grant the runner UAMI permission to read the queue length (KEDA scaler)
  # and grant any receiver principals permission to send messages.
  role_assignments = merge(
    {
      runner_queue_reader = {
        role_definition_id_or_name = "Storage Queue Data Reader"
        principal_id               = local.user_assigned_managed_identity_principal_id
      }
    },
    {
      for pid in var.webhook_receiver_principal_ids :
      "sender_${substr(pid, 0, 8)}" => {
        role_definition_id_or_name = "Storage Queue Data Message Sender"
        principal_id               = pid
      }
    }
  )
  shared_access_key_enabled = false
  tags                      = var.tags
}
