variable "create_user_assigned_managed_identity" {
  type        = bool
  default     = true
  description = "Whether or not to create a user assigned managed identity."
  nullable    = false
}

variable "user_assigned_managed_identity_name" {
  type        = string
  default     = null
  description = "The name of the user assigned managed identity. Must be specified if `create_user_assigned_managed_identity == true`."
}

variable "user_assigned_managed_identity_principal_id" {
  type        = string
  default     = null
  description = "The principal id of the user assigned managed identity. Only required if `create_user_assigned_managed_identity == false`."
}

variable "user_assigned_managed_identity_id" {
  type        = string
  default     = null
  description = "The resource Id of the user assigned managed identity. Only required if `create_user_assigned_managed_identity == false`."
}