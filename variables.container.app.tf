variable "container_app_environment_name" {
  type        = string
  default     = null
  description = "The name of the Container App Environment."
}

variable "container_app_placeholder_job_name" {
  type        = string
  default     = null
  description = "The name of the Container App placeholder job."
}

variable "container_app_job_name" {
  type        = string
  default     = null
  description = "The name of the Container App runner job."
}

variable "max_execution_count" {
  type        = number
  default     = 100
  description = "The maximum number of executions (ADO jobs) to spawn per polling interval."
}

variable "min_execution_count" {
  type        = number
  default     = 0
  description = "The minimum number of executions (ADO jobs) to spawn per polling interval."
}

variable "placeholder_agent_name" {
  type        = string
  default     = "placeholder-agent"
  description = "The name of the agent that will appear in Azure DevOps for the placeholder agent."
}

variable "placeholder_container_name" {
  type        = string
  default     = "ado-agent-linux"
  description = "The name of the container for the placeholder Container Apps job."
}

variable "placeholder_replica_retry_limit" {
  type        = number
  default     = 0
  description = "The number of times to retry the placeholder Container Apps job."
}

variable "placeholder_replica_timeout" {
  type        = number
  default     = 300
  description = "The timeout in seconds for the placeholder Container Apps job."
}

variable "polling_interval_seconds" {
  type        = number
  default     = 30
  description = "How often should the pipeline queue be checked for new events, in seconds."
}

variable "container_cpu" {
  type        = number
  default     = 1.0
  description = "Required CPU in cores, e.g. 0.5"
}

variable "container_memory" {
  type        = string
  default     = "2Gi"
  description = "Required memory, e.g. '250Mb'"
}

variable "container_name" {
  type        = string
  default     = "ado-agent-linux"
  description = "The name of the container for the runner Container Apps job."
}

variable "replica_retry_limit" {
  type        = number
  default     = 3
  description = "The number of times to retry the runner Container Apps job."
}

variable "replica_timeout" {
  type        = number
  default     = 1800
  description = "The timeout in seconds for the runner Container Apps job."
}

variable "target_queue_length" {
  type        = number
  default     = 1
  description = "The target value for the amound of pending jobs to scale on."
}

variable "environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  nullable    = true
  default     = []
  description = "List of additional environment variables to pass to the container."
}

variable "sensitive_environment_variables" {
  type = set(object({
    name  = string
    value = string
    container_app_secret_name = string
    keda_auth_name = optional(string)
  }))
  nullable    = true
  default     = []
  description = "List of additional sensitive environment variables to pass to the container."
}
