variable "container_instance_count" {
  type        = number
  description = "The number of container instances to create"
  default     = 2
}

variable "container_instance_name_prefix" {
  type        = string
  description = "The name prefix of the container instance"
  default     = null
}

variable "container_instance_container_name" {
  type        = string
  description = "The name of the container instance"
  default     = null
}

variable "container_instance_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of additional environment variables to pass to the container."
}

variable "container_instance_sensitive_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  sensitive   = true
  default     = []
  description = "List of additional sensitive environment variables to pass to the container."
}

variable "container_instance_container_cpu" {
  type        = number
  description = "The CPU value for the container instance"
  default     = 2
}

variable "container_instance_container_memory" {
  type        = number
  description = "The memory value for the container instance"
  default     = 4
}

variable "container_instance_container_cpu_limit" {
  type        = number
  description = "The CPU limit value for the container instance"
  default     = 2
}

variable "container_instance_container_memory_limit" {
  type        = number
  description = "The memory limit value for the container instance"
  default     = 4
}

variable "container_instance_use_availability_zones" {
  type        = bool
  description = "Whether to use availability zones for the container instance"
  default     = true
}