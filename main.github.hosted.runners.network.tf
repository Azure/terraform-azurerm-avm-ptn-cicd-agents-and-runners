locals {
  github_hosted_runners_network_settings_name = var.github_hosted_runners_network_settings_name
  github_hosted_runners_subnet_id             = var.github_hosted_runners_subnet_id != null ? var.github_hosted_runners_subnet_id : try(module.github_hosted_runners_vnet[0].subnets["gh-managed-runners"].resource_id, null)
}

resource "azapi_resource" "github_hosted_runners_public_ip" {
  count = var.github_hosted_runners_network_enabled && var.github_hosted_runners_subnet_id == null && var.github_hosted_runners_enable_nat_gateway ? 1 : 0

  location  = var.location
  name      = lower(format("pip-%s-gh", var.postfix))
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/publicIPAddresses@2024-07-01"
  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIPAllocationMethod = "Static"
    }
    zones = var.public_ip_zones
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "github_hosted_runners_nat_gateway" {
  count = var.github_hosted_runners_network_enabled && var.github_hosted_runners_subnet_id == null && var.github_hosted_runners_enable_nat_gateway ? 1 : 0

  location  = var.location
  name      = lower(format("nat-%s-gh", var.postfix))
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/natGateways@2024-07-01"
  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIpAddresses = [
        {
          id = azapi_resource.github_hosted_runners_public_ip[0].id
        }
      ]
    }
    zones = var.public_ip_zones
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

module "github_hosted_runners_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"
  count   = var.github_hosted_runners_network_enabled && var.github_hosted_runners_subnet_id == null ? 1 : 0

  address_space       = [var.github_hosted_runners_vnet_address_space]
  location            = var.location
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  name                = lower(format("vnet-%s-gh", var.postfix))
  subnets = {
    "gh-managed-runners" = merge(
      {
        name             = "gh-managed-runners"
        address_prefixes = [var.github_hosted_runners_subnet_address_prefix]
      },
      var.github_hosted_runners_enable_nat_gateway ? {
        nat_gateway = {
          id = azapi_resource.github_hosted_runners_nat_gateway[0].id
        }
      } : {}
    )
  }
  tags = var.tags
}

resource "azapi_resource" "github_hosted_runners_network_settings" {
  count = var.github_hosted_runners_network_enabled ? 1 : 0

  location  = var.location
  name      = local.github_hosted_runners_network_settings_name
  parent_id = local.resource_group_id
  type      = "GitHub.Network/networkSettings@2024-04-02"
  body = {
    properties = {
      businessId = var.github_hosted_runners_business_id
      subnetId   = local.github_hosted_runners_subnet_id
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = ["tags.GitHubId"]
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [
    module.github_hosted_runners_vnet
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}
