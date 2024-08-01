locals {
  container_app_subnet_address_prefix                       = var.use_private_networking ? (var.container_app_subnet_address_prefix == null ? element(local.subnet_address_prefixes, 0) : var.container_app_subnet_address_prefix) : ""
  container_instance_subnet_address_prefix                  = var.use_private_networking ? (var.container_instance_subnet_address_prefix == null ? element(local.subnet_address_prefixes, length(local.default_subnet_newbits) - 2) : var.container_instance_subnet_address_prefix) : ""
  container_registry_private_endpoint_subnet_address_prefix = var.use_private_networking ? (var.container_registry_private_endpoint_subnet_address_prefix == null ? element(local.subnet_address_prefixes, length(local.default_subnet_newbits) - 1) : var.container_registry_private_endpoint_subnet_address_prefix) : ""
  default_subnet_newbits = concat(
    local.deploy_container_app ? [var.container_app_subnet_cidr_size - local.virtual_network_address_space_cidr_size] : [],
    local.deploy_container_instance ? [var.container_instance_subnet_cidr_size - local.virtual_network_address_space_cidr_size] : [],
    [var.container_registry_subnet_cidr_size - local.virtual_network_address_space_cidr_size]
  )
  subnet_address_prefixes                 = var.use_private_networking ? cidrsubnets(var.virtual_network_address_space, local.default_subnet_newbits...) : []
  virtual_network_address_space_cidr_size = var.use_private_networking ? (var.create_virtual_network ? tonumber(split("/", var.virtual_network_address_space)[1]) : 24) : 0
}