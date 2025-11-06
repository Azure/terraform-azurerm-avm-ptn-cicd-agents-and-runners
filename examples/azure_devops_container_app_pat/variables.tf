variable "azure_devops_agents_personal_access_token" {
  type        = string
  description = "Personal access token for Azure DevOps self-hosted agents (the token requires the 'Agent Pools - Read & Manage' scope and should have the maximum expiry)."
  sensitive   = true
}

variable "azure_devops_organization_name" {
  type        = string
  description = "Azure DevOps Organisation Name"
}

variable "azure_devops_personal_access_token" {
  type        = string
  description = "Personal Access Token for Azure DevOps authentication. Required scopes: Agent Pools (Read & Manage), Build (Read & Execute), Code (Read & Write), Project and Team (Read & Write)"
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
