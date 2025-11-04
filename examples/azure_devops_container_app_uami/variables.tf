# ========================================
# Required Variables
# ========================================

# ========================================
# Optional Variables
# ========================================

# Container app scaling is configured directly in the module call using supported parameters

variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "The personal access token used for agent authentication to Azure DevOps."
  sensitive   = true
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
