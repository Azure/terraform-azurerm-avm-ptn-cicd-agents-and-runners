mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-testagents"
      name = "rg-testagents"
    }
  }
  mock_resource "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-testagents/providers/Microsoft.Network/virtualNetworks/vnet-testagents"
    }
  }
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-testagents/providers/Microsoft.Network/virtualNetworks/vnet-testagents/subnets/snet-testagents"
    }
  }
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-testagents/providers/Microsoft.OperationalInsights/workspaces/laws-testagents"
    }
  }
}

mock_provider "azapi" {}

run "default_configuration" {
  variables {
    name                          = "testagents"
    location                      = "uksouth"
    cicd_system                   = "AzureDevOps"
    azp_url                       = "https://dev.azure.com/my-org"
    container_image_name          = "microsoftavm/azure-devops-agent"
    subnet_address_prefix         = "10.0.2.0/23"
    virtual_network_address_space = "10.0.0.0/16"
  }

  # Resource group is created by default
  assert {
    condition     = azurerm_resource_group.rg[0].name == "rg-testagents"
    error_message = "Expected resource group to be created"
  }

  # Virtual network is created by default
  assert {
    condition     = azurerm_virtual_network.this_vnet[0].name == "vnet-testagents"
    error_message = "Expected virtual network to be created"
  }

  # Subnet is created by default
  assert {
    condition     = azurerm_subnet.this_subnet[0].name == "snet-testagents"
    error_message = "Expected subnet to be created"
  }
}

run "disable_resource_creation" {
  variables {
    name                 = "testagents"
    location             = "uksouth"
    cicd_system          = "AzureDevOps"
    azp_url              = "https://dev.azure.com/my-org"
    container_image_name = "microsoftavm/azure-devops-agent"

    resource_group_creation_enabled = false
    resource_group_name             = "rg-testagents"

    virtual_network_creation_enabled    = false
    virtual_network_name                = "vnet-testagents"
    virtual_network_resource_group_name = "rg-testagents"

    subnet_creation_enabled = false
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-testagents/providers/Microsoft.Network/virtualNetworks/vnet-testagents/subnets/testagents-snet"
  }

  # Resource group should not be created
  assert {
    condition     = try(azurerm_resource_group.rg[0], null) == null
    error_message = "Resource group should not be created"
  }

  # Virtual network should not be created
  assert {
    condition     = try(azurerm_virtual_network.this_vnet[0], null) == null
    error_message = "Virtual network should not be created"
  }

  # Subnet should not be created
  assert {
    condition     = try(azurerm_subnet.this_subnet[0], null) == null
    error_message = "Subnet should not be created"
  }
}