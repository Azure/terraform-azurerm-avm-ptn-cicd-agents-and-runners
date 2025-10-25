# ========================================
# Required Variables
# ========================================

# ========================================
# Optional Variables
# ========================================

# Container app scaling is configured directly in the module call using supported parameters

variable "azure_devops_organization_url" {
  type        = string
  description = "(Required) The full URL of your Azure DevOps organization. Example: https://dev.azure.com/myorg"

  validation {
    condition     = can(regex("^https://dev\\.azure\\.com/[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]/?$", var.azure_devops_organization_url))
    error_message = "The Azure DevOps organization URL must be in format: https://dev.azure.com/organization-name"
  }
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

# Remember to delete this after PR has been merged and tested for the new container image in avm-container-images-cicd-agents-and-runners
variable "default_image_repository_commit" {
  type        = string
  default     = "bc4087f"
  description = "The default image repository commit to use if no custom image is provided."
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
