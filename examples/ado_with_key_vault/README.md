<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module using a personal access token stored in Azure KeyVault.

```hcl
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

# Not required, but useful for checking execution logs.
resource "azurerm_log_analytics_workspace" "this_workspace" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.tags
}

resource "azurerm_virtual_network" "this_vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
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
  enable_telemetry    = var.enable_telemetry
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

module "containerregistry" {
  source              = "Azure/avm-res-containerregistry-registry/azurerm"
  name                = module.naming.container_registry.name_unique
  resource_group_name = azurerm_resource_group.this.name
  role_assignments = {
    acrpull = {
      role_definition_id_or_name = "AcrPull"
      principal_id               = azurerm_user_assigned_identity.example_identity.principal_id
    }
  }
}

# Build the sample container within our new ACR
resource "terraform_data" "agent_container_image" {
  triggers_replace = module.containerregistry.resource_id

  provisioner "local-exec" {
    command = <<COMMAND
az acr build --registry ${module.containerregistry.resource.name} --image "${var.container_image_name}" --file "Dockerfile.azure-pipelines" "https://github.com/Azure-Samples/container-apps-ci-cd-runner-tutorial.git"
COMMAND
  }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "avm-ptn-cicd-agents-and-runners-ca" {
  source = "../.."
  # source             = "Azure/avm-ptn-cicd-agents-and-runners-ca/azurerm"

  resource_group_name = azurerm_resource_group.this.name

  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  }

  name                            = "ca-adoagent"
  azp_pool_name                   = "ca-adoagent-pool"
  azp_url                         = var.ado_organization_url
  pat_token_secret_url            = module.keyvault.resource_secrets["pat-token"].id
  container_image_name            = "${module.containerregistry.resource.login_server}/${var.container_image_name}"
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.this_workspace.id
  container_registry_login_server = module.containerregistry.resource.login_server

  virtual_network_name                = azurerm_virtual_network.this_vnet.name
  virtual_network_resource_group_name = azurerm_virtual_network.this_vnet.resource_group_name
  subnet_address_prefix               = "10.0.2.0/23"

  enable_telemetry = var.enable_telemetry # see variables.tf

  depends_on = [terraform_data.agent_container_image]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0, < 4.0.0)

- <a name="provider_terraform"></a> [terraform](#provider\_terraform)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.this_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_user_assigned_identity.example_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_virtual_network.this_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [terraform_data.agent_container_image](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_ado_organization_url"></a> [ado\_organization\_url](#input\_ado\_organization\_url)

Description: Azure DevOps Organisation URL

Type: `string`

### <a name="input_personal_access_token"></a> [personal\_access\_token](#input\_personal\_access\_token)

Description: The personal access token used for agent authentication to Azure DevOps.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_container_image_name"></a> [container\_image\_name](#input\_container\_image\_name)

Description: Name of the container image to build and push to the container registry

Type: `string`

Default: `"azure-pipelines:latest"`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm-ptn-cicd-agents-and-runners-ca"></a> [avm-ptn-cicd-agents-and-runners-ca](#module\_avm-ptn-cicd-agents-and-runners-ca)

Source: ../..

Version:

### <a name="module_containerregistry"></a> [containerregistry](#module\_containerregistry)

Source: Azure/avm-res-containerregistry-registry/azurerm

Version:

### <a name="module_keyvault"></a> [keyvault](#module\_keyvault)

Source: Azure/avm-res-keyvault-vault/azurerm

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: >= 0.3.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->