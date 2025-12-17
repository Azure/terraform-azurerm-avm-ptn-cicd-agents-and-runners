locals {
  azure_devops_managed_pool_name      = lower(coalesce(var.azure_devops_managed_pool_name, format("mdp-%s", var.postfix)))
  azure_devops_managed_pool_org_name  = trimspace(trimsuffix(replace(replace(replace(var.version_control_system_organization, "https://dev.azure.com/", ""), "https://", ""), "http://", ""), "/"))
  azure_devops_managed_pool_subnet_id = var.azure_devops_managed_pool_subnet_id != null ? var.azure_devops_managed_pool_subnet_id : try(module.azure_devops_managed_pool_vnet[0].subnets["ado-managed-runners"].resource_id, null)
  azure_devops_resource_providers_to_register = {
    dev_center            = { resource_provider = "Microsoft.DevCenter" }
    devops_infrastructure = { resource_provider = "Microsoft.DevOpsInfrastructure" }
  }
}

resource "azapi_resource_action" "azure_devops_managed_pool_resource_provider_registration" {
  for_each = var.azure_devops_managed_pool_enabled ? local.azure_devops_resource_providers_to_register : {}

  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
}

resource "azapi_resource" "azure_devops_managed_pool_public_ip" {
  count = var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null && var.azure_devops_managed_pool_enable_nat_gateway ? 1 : 0

  location  = var.location
  name      = lower(format("pip-%s", local.azure_devops_managed_pool_name))
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

resource "azapi_resource" "azure_devops_managed_pool_nat_gateway" {
  count = var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null && var.azure_devops_managed_pool_enable_nat_gateway ? 1 : 0

  location  = var.location
  name      = lower(format("nat-%s", local.azure_devops_managed_pool_name))
  parent_id = local.resource_group_id
  type      = "Microsoft.Network/natGateways@2024-07-01"
  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      publicIpAddresses = [
        {
          id = azapi_resource.azure_devops_managed_pool_public_ip[0].id
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

resource "azapi_resource" "azure_devops_managed_pool_dev_center" {
  count = var.azure_devops_managed_pool_enabled ? 1 : 0

  location  = var.location
  name      = lower(format("dc-%s", local.azure_devops_managed_pool_name))
  parent_id = local.resource_group_id
  type      = "Microsoft.DevCenter/devcenters@2025-02-01"
  body = {
    properties = {}
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = false
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [azapi_resource_action.azure_devops_managed_pool_resource_provider_registration]
}

resource "azapi_resource" "azure_devops_managed_pool_dev_center_project" {
  count = var.azure_devops_managed_pool_enabled ? 1 : 0

  location  = var.location
  name      = lower(format("dcp-%s", local.azure_devops_managed_pool_name))
  parent_id = local.resource_group_id
  type      = "Microsoft.DevCenter/projects@2025-02-01"
  body = {
    properties = {
      devCenterId = azapi_resource.azure_devops_managed_pool_dev_center[0].id
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = false
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

data "azuread_service_principal" "devops_infrastructure" {
  count = var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null ? 1 : 0

  display_name = "DevOpsInfrastructure"
}

resource "azurerm_role_definition" "azure_devops_managed_pool_subnet_join" {
  count = var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null ? 1 : 0

  name        = format("DevOpsInfra-SubnetJoin-%s", local.azure_devops_managed_pool_name)
  scope       = local.resource_group_id
  description = "Custom role enabling DevOpsInfrastructure to join delegated subnet."

  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/validate/action",
      "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/write",
      "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks/delete"
    ]
  }
}

module "azure_devops_managed_pool_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"
  count   = var.azure_devops_managed_pool_enabled && var.azure_devops_managed_pool_subnet_id == null ? 1 : 0

  address_space       = [var.azure_devops_managed_pool_vnet_address_space]
  location            = var.location
  resource_group_name = local.resource_group_name
  enable_telemetry    = var.enable_telemetry
  name                = lower(format("vnet-%s", local.azure_devops_managed_pool_name))
  role_assignments = {
    subnet_join = {
      role_definition_id_or_name = azurerm_role_definition.azure_devops_managed_pool_subnet_join[0].role_definition_resource_id
      principal_id               = data.azuread_service_principal.devops_infrastructure[0].object_id
    }
  }
  subnets = {
    "ado-managed-runners" = merge(
      {
        name             = "ado-managed-runners"
        address_prefixes = [var.azure_devops_managed_pool_subnet_address_prefix]
        delegation = [{
          name = "Microsoft.DevOpsInfrastructure.pools"
          service_delegation = {
            name = "Microsoft.DevOpsInfrastructure/pools"
          }
        }]
      },
      var.azure_devops_managed_pool_enable_nat_gateway ? {
        nat_gateway = {
          id = azapi_resource.azure_devops_managed_pool_nat_gateway[0].id
        }
      } : {}
    )
  }
  tags = var.tags
}

module "azure_devops_managed_pool" {
  source  = "Azure/avm-res-devopsinfrastructure-pool/azurerm"
  version = "0.3.1"
  count   = var.azure_devops_managed_pool_enabled ? 1 : 0

  dev_center_project_resource_id = azapi_resource.azure_devops_managed_pool_dev_center_project[0].id
  location                       = var.location
  name                           = local.azure_devops_managed_pool_name
  resource_group_name            = local.resource_group_name
  fabric_profile_sku_name        = var.azure_devops_managed_pool_fabric_profile_sku_name
  managed_identities = {
    system_assigned = true
  }
  maximum_concurrency                      = var.azure_devops_managed_pool_maximum_concurrency
  subnet_id                                = local.azure_devops_managed_pool_subnet_id
  subscription_id                          = data.azurerm_client_config.current.subscription_id
  tags                                     = var.tags
  version_control_system_organization_name = local.azure_devops_managed_pool_org_name
  version_control_system_project_names     = var.azure_devops_managed_pool_project_names

  depends_on = [
    module.azure_devops_managed_pool_vnet,
    azapi_resource.azure_devops_managed_pool_dev_center_project,
    azapi_resource_action.azure_devops_managed_pool_resource_provider_registration
  ]
}
