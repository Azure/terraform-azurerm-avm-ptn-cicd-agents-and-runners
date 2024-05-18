provider "azurerm" {
  features {}
}

mock_provider "azurerm" {
  alias = "mock"

  mock_data "azurerm_resource_group" {
    defaults = {
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg"
      name = "my-rg"
    }
  }
  mock_data "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
    }
  }
}

run "default_configuration" {
  command = plan

  variables {
    name                          = "test"
    location                      = "uksouth"
    azp_pool_name                 = "ca-adoagent-pool"
    azp_url                       = "https://dev.azure.com/my-org"
    pat_token_value               = "my-really-secure-token"
    container_image_name          = "microsoftavm/azure-devops-agent"
    subnet_address_prefix         = "10.0.2.0/23"
    virtual_network_address_space = "10.0.0.0/16"
  }

  # Resource group is created by default
  assert {
    condition     = azurerm_resource_group.rg[0].name == "rg-test"
    error_message = "Expected resource group to be created"
  }

  # Virtual network is created by default
  assert {
    condition     = azurerm_virtual_network.ado_agents_vnet[0].name == "vnet-test"
    error_message = "Expected virtual network to be created"
  }

  # Subnet is created by default
  assert {
    condition     = azurerm_subnet.ado_agents_subnet[0].name == "snet-test"
    error_message = "Expected subnet to be created"
  }
}

run "disable_resource_creation" {
  command = plan

  providers = {
    azurerm = azurerm.mock
  }

  variables {
    name                 = "test"
    location             = "uksouth"
    azp_pool_name        = "ca-adoagent-pool"
    azp_url              = "https://dev.azure.com/my-org"
    pat_token_value      = "my-really-secure-token"
    container_image_name = "microsoftavm/azure-devops-agent"

    resource_group_creation_enabled = false
    resource_group_name             = "my-rg"

    virtual_network_creation_enabled    = false
    virtual_network_name                = "my-vnet"
    virtual_network_resource_group_name = "my-rg"

    subnet_creation_enabled = false
    subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
  }

  # Resource group should not be created
  assert {
    condition     = data.azurerm_resource_group.rg[0].name == "my-rg"
    error_message = "Resource group should not be created"
  }

  # Virtual network should not be created
  assert {
    condition     = data.azurerm_virtual_network.ado_agents_vnet[0].name == "my-vnet"
    error_message = "Virtual network should not be created"
  }

  # Subnet should not be created
  assert {
    condition     = azurerm_container_app_environment.this_ca_environment.infrastructure_subnet_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
    error_message = "infrastructure_subnet_id should match provided subnet id"
  }
}