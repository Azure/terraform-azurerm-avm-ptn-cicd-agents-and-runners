variable "user_assigned_managed_identity_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a user assigned managed identity. When using UAMI authentication, the identity must also be configured in Azure DevOps separately."
  nullable    = false
}

variable "user_assigned_managed_identity_id" {
  type        = string
  default     = null
  description = "The resource Id of the user assigned managed identity. Required when `user_assigned_managed_identity_creation_enabled == false`; the module reads `clientId` and `principalId` from this resource. When using UAMI authentication, ensure the identity is configured in Azure DevOps."

  validation {
    condition     = var.user_assigned_managed_identity_creation_enabled || var.user_assigned_managed_identity_id != null
    error_message = "Variable user_assigned_managed_identity_id must be provided when user_assigned_managed_identity_creation_enabled is false."
  }
}

variable "user_assigned_managed_identity_name" {
  type        = string
  default     = null
  description = "The name of the user assigned managed identity. Must be specified if `user_assigned_managed_identity_creation_enabled == true`."
}
