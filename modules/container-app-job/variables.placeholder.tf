variable "placeholder_container_name" {
  type        = string
  default     = null
  description = "The name of the container for the placeholder Container Apps job."
}

variable "placeholder_job_creation_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to create a placeholder job."
}

variable "placeholder_job_name" {
  type        = string
  default     = null
  description = "The name of the Container App placeholder job."
}

variable "placeholder_replica_retry_limit" {
  type        = number
  default     = 3
  description = "The number of times to retry the placeholder Container Apps job."
}

variable "placeholder_replica_timeout" {
  type        = number
  default     = 300
  description = "The timeout in seconds for the placeholder Container Apps job."
}
