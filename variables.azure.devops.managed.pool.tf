variable "azure_devops_managed_pool_enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Create and attach a NAT Gateway to the managed pool subnet when the subnet is created by this module."
}

variable "azure_devops_managed_pool_enabled" {
  type        = bool
  default     = false
  description = "Set to true to deploy an Azure DevOps Managed DevOps Pool (managed runners) with optional VNet injection."
}

variable "azure_devops_managed_pool_fabric_profile_sku_name" {
  type        = string
  default     = "Standard_D2ads_v5"
  description = "VM SKU for the Managed DevOps Pool fabric profile."
}

variable "azure_devops_managed_pool_maximum_concurrency" {
  type        = number
  default     = 2
  description = "Maximum concurrent agents in the Managed DevOps Pool."
}

variable "azure_devops_managed_pool_name" {
  type        = string
  default     = null
  description = "Name of the Azure DevOps Managed DevOps Pool. Defaults to mdp-<postfix>."
}

variable "azure_devops_managed_pool_project_names" {
  type        = set(string)
  default     = []
  description = "Azure DevOps project names the managed pool should serve. Required when azure_devops_managed_pool_enabled is true."

  validation {
    condition     = var.azure_devops_managed_pool_enabled ? length(var.azure_devops_managed_pool_project_names) > 0 : true
    error_message = "azure_devops_managed_pool_project_names must be non-empty when azure_devops_managed_pool_enabled is true."
  }
}

variable "azure_devops_managed_pool_subnet_address_prefix" {
  type        = string
  default     = null
  description = "Subnet address prefix for the managed pool subnet when created (e.g. 10.0.0.0/27). Required when azure_devops_managed_pool_enabled is true and azure_devops_managed_pool_subnet_id is not provided."

  validation {
    condition     = (var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null) ? (var.azure_devops_managed_pool_subnet_address_prefix != null && var.azure_devops_managed_pool_subnet_address_prefix != "") : true
    error_message = "azure_devops_managed_pool_subnet_address_prefix must be set when azure_devops_managed_pool_enabled is true and azure_devops_managed_pool_subnet_id is not provided."
  }
}

variable "azure_devops_managed_pool_subnet_id" {
  type        = string
  default     = null
  description = "Bring-your-own subnet ID for the managed pool. When provided, no VNet/subnet resources are created for the pool."
}

variable "azure_devops_managed_pool_vnet_address_space" {
  type        = string
  default     = null
  description = "Address space for the managed pool VNet when created (e.g. 10.0.0.0/24). Required when azure_devops_managed_pool_enabled is true and azure_devops_managed_pool_subnet_id is not provided."

  validation {
    condition     = (var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null) ? (var.azure_devops_managed_pool_vnet_address_space != null && var.azure_devops_managed_pool_vnet_address_space != "") : true
    error_message = "azure_devops_managed_pool_vnet_address_space must be set when azure_devops_managed_pool_enabled is true and azure_devops_managed_pool_subnet_id is not provided."
  }
}
