variable "user_assigned_managed_identity_client_id" {
  type        = string
  default     = null
  description = "The client id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false` and using UAMI authentication. The identity must be configured in Azure DevOps separately."

  validation {
    condition = (
      !var.user_assigned_managed_identity_creation_enabled && var.version_control_system_type == "azuredevops" && var.version_control_system_authentication_method == "uami" ? var.user_assigned_managed_identity_client_id != null : true
    )
    error_message = "Variable user_assigned_managed_identity_client_id must be defined when using an existing managed identity with UAMI authentication for Azure DevOps."
  }
}

variable "user_assigned_managed_identity_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a user assigned managed identity. When using UAMI authentication, the identity must also be configured in Azure DevOps separately."
  nullable    = false
}

variable "user_assigned_managed_identity_id" {
  type        = string
  default     = null
  description = "The resource Id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false`. When using UAMI authentication, ensure the identity is configured in Azure DevOps."
}

variable "user_assigned_managed_identity_name" {
  type        = string
  default     = null
  description = "The name of the user assigned managed identity. Must be specified if `user_assigned_managed_identity_creation_enabled == true`."
}

variable "user_assigned_managed_identity_principal_id" {
  type        = string
  default     = null
  description = "The principal id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false`. When using UAMI authentication, ensure the identity is configured in Azure DevOps."
}
