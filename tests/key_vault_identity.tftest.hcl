provider "azurerm" {
  features {}
}

run "key_vault_identity_not_specified_for_pat_secret" {
  command = plan

  variables {
    name                          = "test"
    location                      = "uksouth"
    azp_pool_name                 = "ca-adoagent-pool"
    azp_url                       = "https://dev.azure.com/my-org"
    container_image_name          = "microsoftavm/azure-devops-agent"
    subnet_address_prefix         = "10.0.2.0/23"
    virtual_network_address_space = "10.0.0.0/16"

    pat_token_secret_url = "https://keyvault.com/secret/my-pat"
  }

  expect_failures = [
    azapi_resource.runner_job,
    azapi_resource.placeholder_job
  ]
}

run "key_vault_identity_implied_system_managed" {
  command = apply

  variables {
    name                          = "test"
    location                      = "uksouth"
    azp_pool_name                 = "ca-adoagent-pool"
    azp_url                       = "https://dev.azure.com/my-org"
    container_image_name          = "microsoftavm/azure-devops-agent"
    subnet_address_prefix         = "10.0.2.0/23"
    virtual_network_address_space = "10.0.0.0/16"

    pat_token_secret_url = "https://mykeyvault.vault.azure.net/secrets/mysecret"

    managed_identities = {
      system_assigned = true
    }
  }

  assert {
    condition     = jsondecode(azapi_resource.runner_job.body).properties.configuration.secrets[0].identity == "System"
    error_message = "Expected PAT secret to use System identity for accessing KeyVault."
  }
}