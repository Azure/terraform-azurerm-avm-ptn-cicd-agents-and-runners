variable "postfix" {
  type        = string
  description = "Postfix used for naming the resources where the name isn't supplied."

  validation {
    condition     = length(var.postfix) <= 20
    error_message = "Variable 'name' must be less than 20 characters due to container app job naming restrictions. '${var.postfix}' is ${length(var.postfix)} characters."
  }
}

variable "resource_group_id" {
  type        = string
  description = "The id of the resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "The location where the resources will be deployed."
}

variable "container_app_environment_id" {
  type        = string
  description = "The resource id of the Container App Environment."
}

variable "environment_variables" {
  type = set(object({
    name  = string
    value = string
  }))
  description = "List of environment variables to pass to the container."
}

variable "sensitive_environment_variables" {
  type = set(object({
    name  = string
    value = string
    container_app_secret_name = string
    keda_auth_name = optional(string)
  }))
  description = "List of sensitive environment variables to pass to the container."
  sensitive = true
}

variable "registry_login_server" {
  type        = string
  description = "The login server of the container registry."
}

variable "container_image_name" {
  type        = string
  description = "Fully qualified name of the Docker image the agents should run."
  nullable    = false
}


variable "user_assigned_managed_identity_id" {
  type        = string
  description = "The resource Id of the user assigned managed identity."
}
