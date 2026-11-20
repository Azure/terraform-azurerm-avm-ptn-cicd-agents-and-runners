# Unit tests for the `dns_servers` input on the container instance module.
# When not set, no `properties.dnsConfig` block may be emitted so the container
# group keeps Azure's default DNS behavior (168.63.129.16).
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

run "dns_servers_default" {
  command = apply

  assert {
    condition     = azapi_resource.container_group.body.properties.dnsConfig == null
    error_message = "The container group must not set dnsConfig when dns_servers is not provided, but got: ${jsonencode(azapi_resource.container_group.body.properties.dnsConfig)}"
  }
}
