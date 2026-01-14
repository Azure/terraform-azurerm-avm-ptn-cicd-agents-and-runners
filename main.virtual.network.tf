module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"
  count   = var.use_private_networking && var.virtual_network_creation_enabled ? 1 : 0

  address_space       = [var.virtual_network_address_space]
  location            = var.location
  resource_group_name = local.resource_group_name
  name                = local.virtual_network_name
  subnets = merge(local.final_subnets, {
    container_registry_private_endpoint = {
      name           = local.container_registry_private_endpoint_subnet_name
      address_prefix = local.container_registry_private_endpoint_subnet_address_prefix
    }
  })
}

resource "azurerm_private_dns_zone" "container_registry" {
  count = var.use_private_networking && var.container_registry_private_dns_zone_creation_enabled ? 1 : 0

  name                = "privatelink.azurecr.io"
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry" {
  count = var.use_private_networking && var.container_registry_private_dns_zone_creation_enabled ? 1 : 0

  name                  = "privatelink.azurecr.io"
  private_dns_zone_name = azurerm_private_dns_zone.container_registry[0].name
  resource_group_name   = local.resource_group_name
  virtual_network_id    = local.virtual_network_id
  tags                  = var.tags
}

resource "azurerm_public_ip" "this" {
  count = var.use_private_networking && var.public_ip_creation_enabled ? 1 : 0

  allocation_method   = "Static"
  location            = var.location
  name                = local.public_ip_name
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
  zones               = var.use_zone_redundancy ? var.public_ip_zones : null
}

resource "azurerm_nat_gateway" "this" {
  count = var.use_private_networking && var.nat_gateway_creation_enabled ? 1 : 0

  location            = var.location
  name                = local.nat_gateway_name
  resource_group_name = local.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.use_private_networking && var.nat_gateway_creation_enabled ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = local.public_ip_id
}
