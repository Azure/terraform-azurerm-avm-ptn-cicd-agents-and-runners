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

module "virtual_network" {
  count               = var.use_private_networking && var.create_virtual_network ? 1 : 0
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "~> 0.4"
  name                = local.virtual_network_name
  resource_group_name = local.resource_group_name
  location            = var.location
  address_space       = [var.virtual_network_address_space]
  subnets = merge(local.final_subnets, {
    container_registry_private_endpoint = {
      name           = local.container_registry_private_endpoint_subnet_name
      address_prefix = local.container_registry_private_endpoint_subnet_address_prefix
    }
  })
}

resource "azurerm_private_dns_zone" "container_registry" {
  count = var.use_private_networking && var.create_container_registry_private_dns_zone ? 1 : 0

  name                = "privatelink.azurecr.io"
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry" {
  count = var.use_private_networking && var.create_container_registry_private_dns_zone ? 1 : 0

  name                  = "privatelink.azurecr.io"
  private_dns_zone_name = azurerm_private_dns_zone.container_registry[0].name
  resource_group_name   = local.resource_group_name
  virtual_network_id    = module.virtual_network[0].resource_id
  tags                  = var.tags
}

resource "azurerm_public_ip" "this" {
  count = var.use_private_networking && var.create_public_ip ? 1 : 0

  allocation_method   = "Static"
  location            = var.location
  name                = local.public_ip_name
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count = var.use_private_networking && var.create_nat_gateway ? 1 : 0

  location            = var.location
  name                = local.nat_gateway_name
  resource_group_name = local.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.use_private_networking && var.create_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = local.public_ip_id
}
