mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      tenant_id                = "00000000-0000-0000-0000-000000000000"
      object_id                = "00000000-0000-0000-0000-000000000000"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

mock_provider "modtm" {}

mock_provider "random" {}

mock_provider "time" {}

override_resource {
  target = azapi_resource.resource_group[0]
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  }
}

override_resource {
  target = module.virtual_network[0].azapi_resource.vnet
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
  }
}

variables {
  location                            = "eastus2"
  postfix                             = "test"
  version_control_system_type         = "azuredevops"
  version_control_system_organization = "https://dev.azure.com/test"
  virtual_network_address_space       = "10.0.0.0/16"
  enable_telemetry                    = false
}

run "defaults_preserve_subnets_without_nsgs" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = length(module.network_security_group) == 0 && length(local.subnet_network_security_groups) == 0
    error_message = "NSG creation must remain disabled by default."
  }

  assert {
    condition     = alltrue([for subnet in module.virtual_network[0].subnets : subnet.resource.body.properties.networkSecurityGroup == null])
    error_message = "Default subnet requests must retain the existing null NSG association."
  }
}

run "creates_container_app_and_private_endpoint_nsgs" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    network_security_group_creation_enabled = true
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = toset(keys(module.network_security_group)) == toset(["container_app", "container_registry_private_endpoint"])
    error_message = "Each deployed subnet, including the registry private endpoint, must get an NSG."
  }

  assert {
    condition     = alltrue([for key, subnet in module.virtual_network[0].subnets : subnet.resource.body.properties.networkSecurityGroup.id == module.network_security_group[key].resource_id])
    error_message = "Every subnet creation request must include its NSG ID."
  }
}

run "existing_nsg_takes_precedence" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    network_security_group_creation_enabled = true
    subnet_network_security_groups = {
      container_app = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/existing"
      }
    }
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = keys(module.network_security_group) == ["container_registry_private_endpoint"]
    error_message = "An existing NSG must suppress creation only for its own subnet."
  }

  assert {
    condition     = module.virtual_network[0].subnets["container_app"].resource.body.properties.networkSecurityGroup.id == var.subnet_network_security_groups.container_app.id
    error_message = "The subnet request must use the caller's existing NSG."
  }
}

run "creates_container_instance_and_private_endpoint_nsgs" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    network_security_group_creation_enabled = true
    compute_types                           = ["azure_container_instance"]
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = toset(keys(module.network_security_group)) == toset(["container_instance", "container_registry_private_endpoint"])
    error_message = "Container Instances must get their own NSG without creating an unused Container App NSG."
  }

  assert {
    condition     = alltrue([for key, subnet in module.virtual_network[0].subnets : subnet.resource.body.properties.networkSecurityGroup.id == module.network_security_group[key].resource_id])
    error_message = "The Container Instance and registry subnet requests must include their NSGs."
  }
}

run "both_compute_types" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    network_security_group_creation_enabled = true
    compute_types                           = ["azure_container_app", "azure_container_instance"]
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = length(module.network_security_group) == 3 && alltrue([for key, subnet in module.virtual_network[0].subnets : subnet.resource.body.properties.networkSecurityGroup.id == module.network_security_group[key].resource_id])
    error_message = "Both compute types and the registry subnet must each have an NSG."
  }
}

run "existing_nsg_without_creation" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    subnet_network_security_groups = {
      container_registry_private_endpoint = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/existing"
      }
    }
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = length(module.network_security_group) == 0 && module.virtual_network[0].subnets["container_registry_private_endpoint"].resource.body.properties.networkSecurityGroup.id == var.subnet_network_security_groups.container_registry_private_endpoint.id
    error_message = "Existing NSGs must be attached even when creation is disabled."
  }
}

run "public_networking_does_not_create_nsgs" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    network_security_group_creation_enabled = true
    use_private_networking                  = false
    use_zone_redundancy                     = false
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = length(module.network_security_group) == 0 && length(module.virtual_network) == 0
    error_message = "Public networking must not create NSGs or a VNet."
  }
}

run "existing_network_is_not_modified" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    network_security_group_creation_enabled = true
    virtual_network_creation_enabled        = false
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  assert {
    condition     = length(module.network_security_group) == 0 && length(module.virtual_network) == 0
    error_message = "Bring-your-own networking must not create NSGs or manage existing subnets."
  }
}

run "rejects_unknown_subnet_key" {
  command = plan
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    subnet_network_security_groups = {
      typo = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/existing"
      }
    }
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  expect_failures = [var.subnet_network_security_groups]
}

run "rejects_wrong_resource_type" {
  command = plan
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    subnet_network_security_groups = {
      container_app = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/wrong"
      }
    }
  }

  plan_options {
    target = [module.virtual_network, module.network_security_group]
  }

  expect_failures = [var.subnet_network_security_groups]
}
