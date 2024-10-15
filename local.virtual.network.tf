locals {
  container_app_subnet_address_prefix                       = var.use_private_networking && var.virtual_network_creation_enabled ? (var.container_app_subnet_address_prefix == null ? element(local.subnet_address_prefixes, 0) : var.container_app_subnet_address_prefix) : ""
  container_instance_subnet_address_prefix                  = var.use_private_networking && var.virtual_network_creation_enabled ? (var.container_instance_subnet_address_prefix == null ? element(local.subnet_address_prefixes, length(local.default_subnet_newbits) - 2) : var.container_instance_subnet_address_prefix) : ""
  container_registry_private_endpoint_subnet_address_prefix = var.use_private_networking && var.virtual_network_creation_enabled ? (var.container_registry_private_endpoint_subnet_address_prefix == null ? element(local.subnet_address_prefixes, length(local.default_subnet_newbits) - 1) : var.container_registry_private_endpoint_subnet_address_prefix) : ""
  default_subnet_newbits = concat(
    local.deploy_container_app ? [var.container_app_subnet_cidr_size - local.virtual_network_address_space_cidr_size] : [],
    local.deploy_container_instance ? [var.container_instance_subnet_cidr_size - local.virtual_network_address_space_cidr_size] : [],
    [var.container_registry_subnet_cidr_size - local.virtual_network_address_space_cidr_size]
  )
  subnet_address_prefixes                 = var.use_private_networking && var.virtual_network_creation_enabled ? cidrsubnets(var.virtual_network_address_space, local.default_subnet_newbits...) : []
  virtual_network_address_space_cidr_size = var.use_private_networking ? (var.virtual_network_creation_enabled ? tonumber(split("/", var.virtual_network_address_space)[1]) : 24) : 0
}

locals {
  final_subnets = merge(local.subnet_container_app, local.subnet_container_instance)
  subnet_container_app = local.deploy_container_app ? {
    container_app = {
      name           = local.container_app_subnet_name
      address_prefix = local.container_app_subnet_address_prefix
      delegation = [
        {
          name = "Microsoft.App/environments"
          service_delegation = {
            name    = "Microsoft.App/environments"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
      nat_gateway = {
        id = local.nat_gateway_id
      }
    }
  } : {}
  subnet_container_instance = local.deploy_container_instance ? {
    container_instance = {
      name           = local.container_instance_subnet_name
      address_prefix = local.container_instance_subnet_address_prefix
      delegation = [
        {
          name = "Microsoft.ContainerInstance/containerGroups"
          service_delegation = {
            name    = "Microsoft.ContainerInstance/containerGroups"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
      nat_gateway = {
        id = local.nat_gateway_id
      }
    }
  } : {}
}
