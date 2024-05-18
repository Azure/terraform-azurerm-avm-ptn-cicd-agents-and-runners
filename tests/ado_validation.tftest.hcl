provider "azurerm" {
  features {}
}

run "ado_azp_url_must_be_specified" {
  command = plan

  variables {
    name                          = "test"
    location                      = "uksouth"
    cicd_system                   = "AzureDevOps"
    azp_pool_name                 = "ca-adoagent-pool"
    container_image_name          = "microsoftavm/azure-devops-agent"
    subnet_address_prefix         = "10.0.2.0/23"
    virtual_network_address_space = "10.0.0.0/16"
    pat_token                     = "my-pat-token"
  }

  expect_failures = [
    azapi_resource.runner_job,
    azapi_resource.placeholder_job
  ]
}