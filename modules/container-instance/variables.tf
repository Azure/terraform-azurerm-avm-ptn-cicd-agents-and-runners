variable "container_image" {
  type        = string
  description = "Image of the container"
}

variable "container_instance_name" {
  type        = string
  description = "Name of the container instance"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
}

variable "container_registry_login_server" {
  type        = string
  description = "Login server of the container registry"
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The Azure resource id of the parent resource group in which to create the container instance (e.g. `/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>`)."
}

variable "user_assigned_managed_identity_id" {
  type        = string
  description = "ID of the user-assigned managed identity"
}

variable "availability_zones" {
  type        = list(string)
  default     = null
  description = "List of availability zones"
}

variable "container_cpu" {
  type        = number
  default     = 2
  description = "CPU value for the container"
}

variable "container_cpu_limit" {
  type        = number
  default     = 2
  description = "CPU limit for the container"
}

variable "container_memory" {
  type        = number
  default     = 4
  description = "Memory value for the container"
}

variable "container_memory_limit" {
  type        = number
  default     = 4
  description = "Memory limit for the container"
}

variable "container_registry_password" {
  type        = string
  default     = null
  description = "Password of the container registry"
  sensitive   = true
}

variable "container_registry_username" {
  type        = string
  default     = null
  description = "Username of the container registry"
}

variable "environment_variables" {
  type        = map(string)
  default     = {}
  description = "Environment variables for the container"
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["CannotDeleteResource", "ReferencedResourceNotProvisioned"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = "Retry configuration for the resource operations."
  nullable    = false
}

variable "sensitive_environment_variables" {
  type        = map(string)
  default     = {}
  description = "Secure environment variables for the container"
  sensitive   = true
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "ID of the subnet"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = "Per-operation timeouts forwarded to AzAPI resources. When `null`, the provider defaults are used. Values are Go duration strings such as `\"30m\"`."
}

variable "use_private_networking" {
  type        = bool
  default     = true
  description = "Flag to indicate whether to use private networking"
}
