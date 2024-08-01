variable "create_container_app_environment" {
  type        = bool
  default     = true
  description = "Whether or not to create a Container App Environment."
}

variable "container_app_environment_name" {
  type        = string
  default     = null
  description = "The name of the Container App Environment. Only required if `create_container_app_environment` is `true`."
}

variable "container_app_environment_id" {
  type        = string
  default     = null
  description = "The resource id of the Container App Environment. Only required if `create_container_app_environment` is `false`."
}

variable "container_app_job_name" {
  type        = string
  default     = null
  description = "The name of the Container App runner job."
}

variable "container_app_job_container_name" {
  type        = string
  default     = null
  description = "The name of the container for the runner Container Apps job."
}

variable "container_app_placeholder_job_name" {
  type        = string
  default     = null
  description = "The name of the Container App placeholder job."
}

variable "container_app_placeholder_container_name" {
  type        = string
  default     = null
  description = "The name of the container for the placeholder Container Apps job."
}

variable "container_app_max_execution_count" {
  type        = number
  default     = 100
  description = "The maximum number of executions (ADO jobs) to spawn per polling interval."
}

variable "container_app_min_execution_count" {
  type        = number
  default     = 0
  description = "The minimum number of executions (ADO jobs) to spawn per polling interval."
}

variable "container_app_placeholder_replica_retry_limit" {
  type        = number
  default     = 0
  description = "The number of times to retry the placeholder Container Apps job."
}

variable "container_app_placeholder_replica_timeout" {
  type        = number
  default     = 300
  description = "The timeout in seconds for the placeholder Container Apps job."
}

variable "container_app_polling_interval_seconds" {
  type        = number
  default     = 30
  description = "How often should the pipeline queue be checked for new events, in seconds."
}

variable "container_app_container_cpu" {
  type        = number
  default     = 1.0
  description = "Required CPU in cores, e.g. 0.5"
}

variable "container_app_container_memory" {
  type        = string
  default     = "2Gi"
  description = "Required memory, e.g. '250Mb'"
}

variable "container_app_replica_retry_limit" {
  type        = number
  default     = 3
  description = "The number of times to retry the runner Container Apps job."
}

variable "container_app_replica_timeout" {
  type        = number
  default     = 1800
  description = "The timeout in seconds for the runner Container Apps job."
}

variable "container_app_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  nullable    = true
  default     = []
  description = "List of additional environment variables to pass to the container."
}

variable "container_app_sensitive_environment_variables" {
  type = set(object({
    name                      = string
    value                     = string
    container_app_secret_name = string
    keda_auth_name            = optional(string)
  }))
  sensitive = true
  nullable    = true
  default     = []
  description = "List of additional sensitive environment variables to pass to the container."
}

variable "container_app_infrastructure_resource_group_name" {
  type        = string
  default     = null
  description = "The name of the resource group where the Container Apps infrastructure is deployed."
}

variable "container_app_placeholder_schedule_offset_minutes" {
  type        = number
  default     = 5
  description = "The offset in minutes for the placeholder job."
}
