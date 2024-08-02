variable "user_assigned_managed_identity_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a user assigned managed identity."
  nullable    = false
}

variable "user_assigned_managed_identity_name" {
  type        = string
  default     = null
  description = "The name of the user assigned managed identity. Must be specified if `user_assigned_managed_identity_creation_enabled == true`."
}

variable "user_assigned_managed_identity_principal_id" {
  type        = string
  default     = null
  description = "The principal id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false`."
}

variable "user_assigned_managed_identity_id" {
  type        = string
  default     = null
  description = "The resource Id of the user assigned managed identity. Only required if `user_assigned_managed_identity_creation_enabled == false`."
}