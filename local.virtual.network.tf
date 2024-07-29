locals {
  virtual_network_address_space_cidr_size = var.create_virtual_network ? tonumber(split("/", var.virtual_network_address_space)[1]) : 24

  subnet_address_prefixes = cidrsubnets(var.virtual_network_address_space, 23 - local.virtual_network_address_space_cidr_size, 29 - local.virtual_network_address_space_cidr_size)
  container_app_subnet_address_prefix = var.container_app_subnet_address_prefix == null ? element(local.subnet_address_prefixes, 0) : var.container_app_subnet_address_prefix
  container_registry_private_endpoint_subnet_address_prefix = var.container_registry_private_endpoint_subnet_address_prefix == null ? element(local.subnet_address_prefixes, 1) : var.container_registry_private_endpoint_subnet_address_prefix
}