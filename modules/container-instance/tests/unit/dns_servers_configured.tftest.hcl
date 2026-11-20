# Unit tests for the `dns_servers` input on the container instance module.
# When set, the container group body must carry a top-level `properties.dnsConfig`
# with the configured name servers (API version 2024-05-01-preview), replacing
# Azure's default DNS server (168.63.129.16).
# Runs at apply time with mocked providers - no Azure resources are deployed.
# Execute with: avm test unit

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  container_image                   = "azure-devops-agent:9b4c292"
  container_instance_name           = "ci-dnstest"
  container_name                    = "container-dnstest"
  container_registry_login_server   = "example.azurecr.io"
  location                          = "eastus2"
  parent_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  user_assigned_managed_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"
  subnet_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-ci"
  enable_telemetry                  = false
}

run "dns_servers_configured" {
  command = apply

  variables {
    dns_servers = ["10.1.1.11", "10.1.1.12"]
  }

  assert {
    condition     = toset(azapi_resource.container_group.body.properties.dnsConfig.nameServers) == toset(["10.1.1.11", "10.1.1.12"])
    error_message = "The container group must use the configured DNS servers, but dnsConfig was: ${jsonencode(azapi_resource.container_group.body.properties.dnsConfig)}"
  }

  assert {
    condition     = azapi_resource.container_group.body.properties.osType == "Linux"
    error_message = "The container group osType must remain Linux when DNS servers are configured."
  }
}
