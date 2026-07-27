variable "webhook_queue_length_per_runner" {
  type        = number
  default     = 1
  description = "KEDA `queueLength` metadata - how many messages in the queue trigger one additional runner. Default `1` means one runner per queued job. Only used when `webhook_scaling_enabled` is `true`."

  validation {
    condition     = var.webhook_queue_length_per_runner >= 1
    error_message = "webhook_queue_length_per_runner must be >= 1."
  }
}

variable "webhook_queue_name" {
  type        = string
  default     = "runner-jobs"
  description = "Name of the Storage Queue used to trigger runner scale-up. Only used when `webhook_scaling_enabled` is `true`."

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$", var.webhook_queue_name))
    error_message = "webhook_queue_name must be a valid Storage Queue name (3-63 lowercase alphanumeric/hyphen, starting and ending with letter or digit)."
  }
}

variable "webhook_receiver_principal_ids" {
  type        = set(string)
  default     = []
  description = <<DESCRIPTION
Principal IDs (object IDs) of identities that should be granted `Storage Queue Data Message Sender`
on the webhook queue. Typically the managed identity of the Azure Function / Logic App that receives
webhooks and writes to the queue. Only used when `webhook_scaling_enabled` is `true`.
DESCRIPTION
  nullable    = false
}

variable "webhook_scaling_enabled" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
Whether to enable webhook-driven KEDA scaling instead of the default polling scalers
(`github-runner` / `azure-pipelines`).

When `false` (default), KEDA polls the GitHub/Azure DevOps API every
`container_app_polling_interval_seconds` to detect queued jobs. Simple, but adds
0-30s of latency per job and consumes API rate limit.

When `true`, this module provisions a private Storage Account + Storage Queue and
KEDA scales the runner job on **queue length** using the `azure-queue` scaler with
UAMI auth (no secrets). A webhook receiver (out of scope for this module - typically
an Azure Function, Logic App, or APIM policy in a hub/online landing zone) translates
GitHub `workflow_job` / Azure DevOps service hook events into queue messages.

See `WEBHOOKS.md` for the receiver contract, sample Python Function App, secret
rotation guidance, and caveats.

Webhook mode gives sub-second scale-up latency and eliminates API polling load, at
the cost of operating an additional receiver component.
DESCRIPTION
  nullable    = false
}

variable "webhook_storage_account_name" {
  type        = string
  default     = null
  description = "Name of the Storage Account that hosts the webhook queue. If null, defaults to `stwh<postfix>` (hyphens removed). Only used when `webhook_scaling_enabled` is `true`."

  validation {
    condition     = var.webhook_storage_account_name == null ? true : can(regex("^[a-z0-9]{3,24}$", var.webhook_storage_account_name))
    error_message = "webhook_storage_account_name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "webhook_storage_private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Resource ID of the subnet for the webhook Storage Account private endpoint. If null, falls back to `container_registry_private_endpoint_subnet_id`. Only used when `webhook_scaling_enabled` is `true`."
}

variable "webhook_storage_queue_dns_zone_id" {
  type        = string
  default     = null
  description = "Resource ID of the private DNS zone for Storage Queue (`privatelink.queue.core.windows.net`). If null, DNS is assumed to be handled by Azure Policy or central DNS. Only used when `webhook_scaling_enabled` is `true`."
}
