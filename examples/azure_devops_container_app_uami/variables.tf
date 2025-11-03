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

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) Additional tags to apply to all resources."
}

variable "compute_types" {
  type        = list(string)
  default     = ["azure_container_app"]
  description = "(Optional) List of compute types to deploy. Valid options: 'azure_container_app', 'azure_container_instance'."

  validation {
    condition = alltrue([
      for compute_type in var.compute_types :
      contains(["azure_container_app", "azure_container_instance"], compute_type)
    ])
    error_message = "Compute types must be one of: 'azure_container_app', 'azure_container_instance'."
  }
}

variable "environment" {
  type        = string
  default     = "demo"
  description = "(Optional) The environment name for resource tagging and naming."
}

variable "location" {
  type        = string
  default     = "East US 2"
  description = "(Optional) The Azure region where resources will be deployed."

  validation {
    condition     = can(regex("^[a-z0-9 ]+$", lower(var.location)))
    error_message = "The location must be a valid Azure region name."
  }
}

variable "use_private_networking" {
  type        = bool
  default     = false
  description = "(Optional) Whether to use private networking for the container registry. Set to false for local development."
}

variable "virtual_network_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "(Optional) The address space for the virtual network in CIDR notation."

  validation {
    condition     = can(cidrhost(var.virtual_network_address_space, 0))
    error_message = "The virtual network address space must be a valid CIDR block."
  }
}
