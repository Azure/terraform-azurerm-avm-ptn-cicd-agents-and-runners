variable "container_instance_container_cpu" {
  type        = number
  default     = 2
  description = "The CPU value for the container instance"
}

variable "container_instance_container_cpu_limit" {
  type        = number
  default     = 2
  description = "The CPU limit value for the container instance"
}

variable "container_instance_container_memory" {
  type        = number
  default     = 4
  description = "The memory value for the container instance"
}

variable "container_instance_container_memory_limit" {
  type        = number
  default     = 4
  description = "The memory limit value for the container instance"
}

variable "container_instance_container_name" {
  type        = string
  default     = null
  description = "The name of the container instance"
}

variable "container_instance_count" {
  type        = number
  default     = 2
  description = "The number of container instances to create"
}

variable "container_instance_dns_servers" {
  type        = list(string)
  default     = null
  description = "List of DNS server IP addresses to configure on the container instances. When set, the container instances use these DNS servers instead of Azure's default DNS (168.63.129.16), which allows them to resolve private DNS zones linked to custom or VNet DNS servers. Changing this value forces replacement of the container instances."
}

variable "container_instance_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of additional environment variables to pass to the container."
}

variable "container_instance_name_prefix" {
  type        = string
  default     = null
  description = "The name prefix of the container instance"
}

variable "container_instance_sensitive_environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  default     = []
  description = "List of additional sensitive environment variables to pass to the container."
  sensitive   = true
}

variable "container_instance_use_availability_zones" {
  type        = bool
  default     = true
  description = "Whether to use availability zones for the container instance"
}
