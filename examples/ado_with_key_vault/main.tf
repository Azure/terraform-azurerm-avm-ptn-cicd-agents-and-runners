locals {
  tags = {
    scenario = "with_key_vault"
  }
}

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "this" {}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
  tags     = local.tags
}

resource "azurerm_user_assigned_identity" "example_identity" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

module "keyvault" {
  source              = "Azure/avm-res-keyvault-vault/azurerm"
  name                = module.naming.key_vault.name_unique
  enable_telemetry    = true
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.this.tenant_id

  network_acls = null

  secrets = {
    pat-token = {
      name = "pat-token"
    }
  }

  secrets_value = {
    pat-token = var.personal_access_token
  }

  role_assignments = {
    # Required for container app environments to be able to read PAT token from KeyVault.
    secrets_reader = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = azurerm_user_assigned_identity.example_identity.principal_id
    },

    # Required to set PAT token.
    current_user = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.this.object_id
    }
  }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "avm-ptn-cicd-agents-and-runners-ca" {
  source = "../.."
  # source             = "Azure/avm-ptn-cicd-agents-and-runners-ca/azurerm"

  resource_group_creation_enabled = false
  resource_group_name             = azurerm_resource_group.this.name

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  }

  name                          = module.naming.container_app.name_unique
  cicd_system                   = "AzureDevOps"
  pat_token_secret_url          = module.keyvault.resource_secrets["pat-token"].id
  container_image_name          = "microsoftavm/azure-devops-agent:1.1.0"
  subnet_address_prefix         = "10.0.2.0/23"
  virtual_network_address_space = "10.0.0.0/16"

  # For Azure Pipelines
  azp_pool_name = "ca-adoagent-pool"
  azp_url       = var.ado_organization_url

  enable_telemetry = true
}