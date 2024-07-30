variable "create_placeholder_job" {
  type        = bool
  description = "Whether or not to create a placeholder job."
  default     = false
}

variable "placeholder_job_name" {
  type        = string
  description = "The name of the Container App placeholder job."
  default     = null
}

variable "placeholder_agent_name" {
  type        = string
  description = "The name of the agent / runner that will appear in Azure DevOps / GitHub for the placeholder agent."
  default     = null
}

variable "placeholder_container_name" {
  type        = string
  description = "The name of the container for the placeholder Container Apps job."
  default     = null
}

variable "placeholder_replica_retry_limit" {
  type        = number
  description = "The number of times to retry the placeholder Container Apps job."
  default     = 3
}

variable "placeholder_replica_timeout" {
  type        = number
  description = "The timeout in seconds for the placeholder Container Apps job."
  default     = 300
}
