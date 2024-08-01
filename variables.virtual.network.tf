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
  default     = null
  description = "The address space for the virtual network. Must be specified if `create_virtual_network == false`."
}

variable "container_app_subnet_name" {
  type        = string
  default     = null
  description = "The name of the subnet. Must be specified if `create_virtual_network == false`."
}

variable "container_app_subnet_address_prefix" {
  type        = string
  default     = null
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
}

variable "container_app_subnet_id" {
  type        = string
  default     = null
  description = "The ID of a pre-existing subnet to use. Required if `create_virtual_network` is `false`."
}

variable "container_registry_private_endpoint_subnet_name" {
  type        = string
  default     = null
  description = "The name of the subnet. Must be specified if `create_virtual_network == false`."
}

variable "container_registry_private_endpoint_subnet_address_prefix" {
  type        = string
  default     = null
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
}

variable "container_registry_private_endpoint_subnet_id" {
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

variable "create_container_registry_private_dns_zone" {
  type        = bool
  default     = true
  description = "Whether or not to create a private DNS zone for the container registry."
}

variable "container_registry_dns_zone_id" {
  type        = string
  default     = null
  description = "The ID of the private DNS zone to create for the container registry. Only required if `create_private_dns_zone` is `false`."
}

variable "create_public_ip" {
  type        = bool
  default     = true
  description = "Whether or not to create a public IP."
}

variable "public_ip_name" {
  type        = string
  default     = null
  description = "The name of the public IP."
}

variable "public_ip_id" {
  type        = string
  default     = null
  description = "The ID of the public IP. Only required if `create_public_ip` is `false`."
}

variable "create_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether or not to create a NAT Gateway."
}

variable "nat_gateway_name" {
  type        = string
  default     = null
  description = "The name of the NAT Gateway."
}

variable "nat_gateway_id" {
  type        = string
  default     = null
  description = "The ID of the NAT Gateway. Only required if `create_nat_gateway` is `false`."
}