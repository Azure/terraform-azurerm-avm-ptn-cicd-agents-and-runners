variable "container_instance_name" {
  description = "Name of the container instance"
  type        = string
}

variable "location" {
  description = "Location of the container instance"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "use_private_networking" {
  description = "Flag to indicate whether to use private networking"
  type        = bool
  default = true
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
  default = null
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = [1]
}

variable "user_assigned_managed_identity_id" {
  description = "ID of the user-assigned managed identity"
  type        = string
}

variable "container_registry_login_server" {
  description = "Login server of the container registry"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Image of the container"
  type        = string
}

variable "container_cpu" {
  description = "CPU value for the container"
  type        = number
  default     = 2
}

variable "container_memory" {
  description = "Memory value for the container"
  type        = number
  default     =  4
}

variable "container_cpu_limit" {
  description = "CPU limit for the container"
  type        = number
  default     = 2
}

variable "container_memory_limit" {
  description = "Memory limit for the container"
  type        = number
  default     = 4
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default = {}
}

variable "sensitive_environment_variables" {
  description = "Secure environment variables for the container"
  type        = map(string)
  sensitive = true
  default = {}
}
