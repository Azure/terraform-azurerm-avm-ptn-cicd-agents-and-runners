module "virtual_network" {
  count   = var.create_virtual_network ? 1 : 0
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.4"
  
  name                     = var.virtual_network_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  address_space            = [var.virtual_network_address_space]

  subnets = {
    agents = {
      name                 = var.subnet_name
      address_prefix       = var.subnet_address_prefix
    }
  }
}
