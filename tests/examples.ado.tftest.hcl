provider "azurerm" {
  features {}
}

run "default" {
  variables {
    personal_access_token = "my-really-secure-token"
    ado_organization_url  = "https://dev.azure.com/my-org"
  }

  module {
    source = "./examples/default"
  }
}