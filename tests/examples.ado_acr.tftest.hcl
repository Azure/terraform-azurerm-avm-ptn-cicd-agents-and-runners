provider "azurerm" {
  features {}
}

run "ado_with_azure_container_registry" {
  variables {
    personal_access_token = "my-really-secure-token"
    ado_organization_url  = "https://dev.azure.com/my-org"
  }

  module {
    source = "./examples/ado_with_azure_container_registry"
  }
}