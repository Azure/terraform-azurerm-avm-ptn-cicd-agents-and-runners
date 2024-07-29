module "virtual_network" {
  count   = var.create_virtual_network ? 1 : 0
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.4"
  
  name                     = local.virtual_network_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  address_space            = [var.virtual_network_address_space]

  subnets = {
    container_app = {
      name                 = local.container_app_subnet_name
      address_prefix       = local.container_app_subnet_address_prefix
    }
    container_registry_private_endpoint = {
      name                 = local.container_registry_private_endpoint_subnet_name
      address_prefix       = local.container_registry_private_endpoint_subnet_address_prefix
    }
  }
}
