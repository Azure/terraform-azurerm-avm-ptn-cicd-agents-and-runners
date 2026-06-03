variable "log_analytics_workspace_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a log analytics workspace."
  nullable    = false

  validation {
    condition     = var.log_analytics_workspace_creation_enabled || !contains(var.compute_types, "azure_container_app") || !var.container_app_environment_creation_enabled || var.log_analytics_workspace_resource_id != null || var.log_analytics_workspace_id != null
    error_message = "When creating a Container App Environment with log_analytics_workspace_creation_enabled set to false, you must provide log_analytics_workspace_resource_id (preferred) or the legacy log_analytics_workspace_id pointing at an existing Log Analytics Workspace."
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Deprecated. Legacy alias for `log_analytics_workspace_resource_id`. The resource ID of an existing Log Analytics Workspace. New consumers should use `log_analytics_workspace_resource_id`. If both are set they must match."

  validation {
    condition     = var.log_analytics_workspace_id == null || can(provider::azapi::parse_resource_id("Microsoft.OperationalInsights/workspaces@2023-09-01", var.log_analytics_workspace_id))
    error_message = "Variable log_analytics_workspace_id must be a valid Log Analytics Workspace resource ID (e.g. /subscriptions/<id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<name>)."
  }
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "The name of the log analytics workspace. Only required if `log_analytics_workspace_creation_enabled == false`."
}

variable "log_analytics_workspace_resource_id" {
  type        = string
  default     = null
  description = "The resource ID of an existing Log Analytics Workspace to attach to the Container App Environment when `log_analytics_workspace_creation_enabled` is `false`. Preferred over the legacy `log_analytics_workspace_id` input."

  validation {
    condition     = var.log_analytics_workspace_resource_id == null || can(provider::azapi::parse_resource_id("Microsoft.OperationalInsights/workspaces@2023-09-01", var.log_analytics_workspace_resource_id))
    error_message = "Variable log_analytics_workspace_resource_id must be a valid Log Analytics Workspace resource ID (e.g. /subscriptions/<id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<name>)."
  }
  validation {
    condition     = var.log_analytics_workspace_resource_id == null || var.log_analytics_workspace_id == null || var.log_analytics_workspace_resource_id == var.log_analytics_workspace_id
    error_message = "Only one Log Analytics Workspace ID should be provided. If both log_analytics_workspace_resource_id and the legacy log_analytics_workspace_id are set, they must match."
  }
}

variable "log_analytics_workspace_retention_in_days" {
  type        = number
  default     = 30
  description = "The retention period for the Log Analytics Workspace."
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "The SKU of the Log Analytics Workspace."
}
