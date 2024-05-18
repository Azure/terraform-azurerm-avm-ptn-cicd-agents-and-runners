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

// run "github" {
//   variables {
//     personal_access_token = "my-really-secure-token"
//   }

//   module {
//     source = "./examples/github"
//   }
// }

// run "ado_with_azure_container_registry" {
//   variables {
//     personal_access_token = "my-really-secure-token"
//     ado_organization_url  = "https://dev.azure.com/my-org"
//   }

//   module {
//     source = "./examples/ado_with_azure_container_registry"
//   }
// }

// run "ado_with_key_vault" {
//   variables {
//     personal_access_token = "my-really-secure-token"
//     ado_organization_url  = "https://dev.azure.com/my-org"
//   }

//   module {
//     source = "./examples/ado_with_key_vault"
//   }
// }