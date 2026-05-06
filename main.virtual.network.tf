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

resource "azapi_resource" "private_dns_zone_container_registry" {
  count = var.use_private_networking && var.container_registry_private_dns_zone_creation_enabled ? 1 : 0

  location  = "global"
  name      = "privatelink.azurecr.io"
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/privateDnsZones@2024-06-01"
  body = {
    properties = {}
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["id", "name"]
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [azapi_resource.resource_group]
}

resource "azapi_resource" "private_dns_zone_virtual_network_link_container_registry" {
  count = var.use_private_networking && var.container_registry_private_dns_zone_creation_enabled ? 1 : 0

  location  = "global"
  name      = "privatelink.azurecr.io"
  parent_id = azapi_resource.private_dns_zone_container_registry[0].id
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01"
  body = {
    properties = {
      virtualNetwork = {
        id = local.virtual_network_id
      }
      registrationEnabled = false
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "public_ip" {
  count = var.use_private_networking && var.public_ip_creation_enabled ? 1 : 0

  location  = var.location
  name      = local.public_ip_name
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/publicIPAddresses@2024-05-01"
  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIPAllocationMethod = "Static"
    }
    zones = var.use_zone_redundancy ? var.public_ip_zones : null
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["id"]
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [azapi_resource.resource_group]
}

resource "azapi_resource" "nat_gateway" {
  count = var.use_private_networking && var.nat_gateway_creation_enabled ? 1 : 0

  location  = var.location
  name      = local.nat_gateway_name
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/natGateways@2024-05-01"
  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIpAddresses = [
        {
          id = local.public_ip_id
        }
      ]
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["id"]
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [azapi_resource.resource_group]
}
