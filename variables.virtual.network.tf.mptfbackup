variable "container_app_subnet_address_prefix" {
  type        = string
  default     = null
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
}

variable "container_app_subnet_cidr_size" {
  type        = number
  default     = 27
  description = "The CIDR size for the container instance subnet."
}

variable "container_app_subnet_id" {
  type        = string
  default     = null
  description = "The ID of a pre-existing subnet to use. Required if `virtual_network_creation_enabled` is `false`."
}

variable "container_app_subnet_name" {
  type        = string
  default     = null
  description = "The name of the subnet. Must be specified if `virtual_network_creation_enabled` is `true`."
}

variable "container_instance_subnet_address_prefix" {
  type        = string
  default     = null
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
}

variable "container_instance_subnet_cidr_size" {
  type        = number
  default     = 28
  description = "The CIDR size for the container instance subnet."
}

variable "container_instance_subnet_id" {
  type        = string
  default     = null
  description = "The ID of a pre-existing subnet to use. Required if `virtual_network_creation_enabled` is `false`."
}

variable "container_instance_subnet_name" {
  type        = string
  default     = null
  description = "The name of the subnet. Must be specified if `virtual_network_creation_enabled == false`."
}

variable "container_registry_dns_zone_id" {
  type        = string
  default     = null
  description = "The ID of the private DNS zone to create for the container registry. Only required if `container_registry_private_dns_zone_creation_enabled` is `false` and you are not using policy to update the DNS zone."
}

variable "container_registry_private_dns_zone_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a private DNS zone for the container registry."
}

variable "container_registry_private_endpoint_subnet_address_prefix" {
  type        = string
  default     = null
  description = "The address prefix for the Container App Environment. Either subnet_id or subnet_name and subnet_address_prefix must be specified."
}

variable "container_registry_private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "The ID of a pre-existing subnet to use. Required if `virtual_network_creation_enabled` is `false`."
}

variable "container_registry_private_endpoint_subnet_name" {
  type        = string
  default     = null
  description = "The name of the subnet. Must be specified if `virtual_network_creation_enabled == false`."
}

variable "container_registry_subnet_cidr_size" {
  type        = number
  default     = 29
  description = "The CIDR size for the container registry subnet."
}

variable "nat_gateway_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a NAT Gateway."
}

variable "nat_gateway_id" {
  type        = string
  default     = null
  description = "The ID of the NAT Gateway. Only required if `nat_gateway_creation_enabled` is `false`."
}

variable "nat_gateway_name" {
  type        = string
  default     = null
  description = "The name of the NAT Gateway."
}

variable "public_ip_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a public IP."
}

variable "public_ip_id" {
  type        = string
  default     = null
  description = "The ID of the public IP. Only required if `public_ip_creation_enabled` is `false`."
}

variable "public_ip_name" {
  type        = string
  default     = null
  description = "The name of the public IP."
}

variable "public_ip_zones" {
  type        = set(string)
  default     = ["1", "2", "3"]
  description = "The availability zones for the public IP. Only required if `public_ip_creation_enabled` is `true`."
}

variable "virtual_network_address_space" {
  type        = string
  default     = null
  description = "The address space for the virtual network. Must be specified if `virtual_network_creation_enabled` is `true`."
}

variable "virtual_network_creation_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a virtual network."
}

variable "virtual_network_id" {
  type        = string
  default     = null
  description = "The ID of the virtual network. Only required if `virtual_network_creation_enabled` is `false`."
}

variable "virtual_network_name" {
  type        = string
  default     = null
  description = "The name of the virtual network. Must be specified if `virtual_network_creation_enabled` is `true`."
}
