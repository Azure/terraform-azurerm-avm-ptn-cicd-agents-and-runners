variable "log_analytics_workspace_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a log analytics workspace."
  nullable    = false
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The resource Id of the Log Analytics Workspace."
}

variable "log_analytics_workspace_name" {
  type        = string
  default     = null
  description = "The name of the log analytics workspace. Only required if `log_analytics_workspace_creation_enabled == false`."
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
