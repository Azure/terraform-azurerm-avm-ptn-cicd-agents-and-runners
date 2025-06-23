variable "job_container_name" {
  type        = string
  description = "The name of the container for the runner Container Apps job."
}

variable "job_name" {
  type        = string
  description = "The name of the Container App job."
}

variable "max_execution_count" {
  type        = number
  description = "The maximum number of executions to spawn per polling interval."
}

variable "min_execution_count" {
  type        = number
  description = "The minimum number of executions to spawn per polling interval."
}

variable "polling_interval_seconds" {
  type        = number
  description = "How often should the pipeline queue be checked for new events, in seconds."
}

variable "replica_retry_limit" {
  type        = number
  description = "The number of times to retry the runner Container Apps job."
}

variable "replica_timeout" {
  type        = number
  description = "The timeout in seconds for the runner Container Apps job."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
