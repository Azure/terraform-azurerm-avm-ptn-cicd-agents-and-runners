provider "azurerm" {
  features {}
}

run "github" {
  variables {
    personal_access_token = "my-really-secure-token"
  }

  module {
    source = "./examples/github"
  }
}