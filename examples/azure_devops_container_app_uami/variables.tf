variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

# Optional override variables - most values are hardcoded in main.tf for simplicity
variable "location_override" {
  type        = string
  default     = null
  description = "(Optional) Override the automatically selected Azure region. If not specified, a region is chosen automatically."

  validation {
    condition     = var.location_override == null || can(regex("^[a-z0-9 ]+$", lower(var.location_override)))
    error_message = "The location override must be a valid Azure region name."
  }
}
