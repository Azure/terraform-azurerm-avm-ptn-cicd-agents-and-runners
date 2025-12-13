variable "github_hosted_runners_business_id" {
  type        = string
  default     = null
  description = "GitHub Enterprise business ID used by GitHub hosted runners Azure private networking. Required when github_hosted_runners_network_enabled is true."

  validation {
    condition     = var.github_hosted_runners_network_enabled ? (var.github_hosted_runners_business_id != null && var.github_hosted_runners_business_id != "") : true
    error_message = "github_hosted_runners_business_id must be set when github_hosted_runners_network_enabled is true."
  }
}

variable "github_hosted_runners_enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Create and attach a NAT Gateway to the GitHub hosted runners subnet when the subnet is created by this module."
}

variable "github_hosted_runners_network_enabled" {
  type        = bool
  default     = false
  description = "Set to true to configure GitHub-hosted runners Azure private networking (GitHub.Network/networkSettings) with optional VNet/subnet creation."
}

variable "github_hosted_runners_network_settings_name" {
  type        = string
  default     = "gh-managed-runners"
  description = "Name for the GitHub Network Settings resource."
}

variable "github_hosted_runners_subnet_address_prefix" {
  type        = string
  default     = null
  description = "Subnet address prefix for the GitHub hosted runners subnet when created (e.g. 10.0.0.0/27). Required when github_hosted_runners_network_enabled is true and github_hosted_runners_subnet_id is not provided."

  validation {
    condition     = (var.github_hosted_runners_network_enabled && var.github_hosted_runners_subnet_id == null) ? (var.github_hosted_runners_subnet_address_prefix != null && var.github_hosted_runners_subnet_address_prefix != "") : true
    error_message = "github_hosted_runners_subnet_address_prefix must be set when github_hosted_runners_network_enabled is true and github_hosted_runners_subnet_id is not provided."
  }
}

variable "github_hosted_runners_subnet_id" {
  type        = string
  default     = null
  description = "Bring-your-own subnet ID for GitHub hosted runners Azure private networking. When provided, no VNet/subnet resources are created."
}

variable "github_hosted_runners_vnet_address_space" {
  type        = string
  default     = null
  description = "Address space for the GitHub hosted runners VNet when created (e.g. 10.0.0.0/24). Required when github_hosted_runners_network_enabled is true and github_hosted_runners_subnet_id is not provided."

  validation {
    condition     = (var.github_hosted_runners_network_enabled && var.github_hosted_runners_subnet_id == null) ? (var.github_hosted_runners_vnet_address_space != null && var.github_hosted_runners_vnet_address_space != "") : true
    error_message = "github_hosted_runners_vnet_address_space must be set when github_hosted_runners_network_enabled is true and github_hosted_runners_subnet_id is not provided."
  }
}
