variable "create_virtual_network" {
  type        = bool
  default     = true
  description = "Whether or not to create a virtual network."
}

variable "virtual_network_name" {
  type        = string
  default     = null
  description = "The name of the virtual network. Must be specified if `create_virtual_network == false`."
}

variable "virtual_network_address_space" {
  type        = string
  default = null
  description = "The address space for the virtual network. Must be specified if `create_virtual_network == false`."
}

variable "subnet_name" {
  type        = string
  default = null
  description = "The name of the subnet. Must be specified if `create_virtual_network == false`."
}

variable "subnet_address_prefix" {
  type        = string
  default     = null
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "The ID of a pre-existing subnet to use. Required if `create_virtual_network` is `false`."
}

variable "virtual_network_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the Virtual Network's Resource Group. Must be specified if `virtual_network_creation_enabled` == `false`"
  nullable    = false
}
