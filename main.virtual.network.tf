module "virtual_network" {
  count   = var.use_private_networking && var.create_virtual_network ? 1 : 0
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.4"

  name                = local.virtual_network_name
  resource_group_name = local.resource_group_name
  location            = var.location
  address_space       = [var.virtual_network_address_space]

  subnets = {
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
    }
    container_registry_private_endpoint = {
      name           = local.container_registry_private_endpoint_subnet_name
      address_prefix = local.container_registry_private_endpoint_subnet_address_prefix
    }
  }
}

resource "azurerm_private_dns_zone" "container_registry" {
  count               = var.use_private_networking && var.create_container_registry_private_dns_zone ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry" {
  count                 = var.use_private_networking && var.create_container_registry_private_dns_zone ? 1 : 0
  name                  = "privatelink.azurecr.io"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_registry[0].name
  virtual_network_id    = module.virtual_network[0].resource_id
}
