<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
locals {
  tags = {
    scenario = "default"
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

# This is the module call
module "avm-ptn-cicd-agents-and-runners-ca" {
  source = "../.."
  # source             = "Azure/avm-ptn-cicd-agents-and-runners-ca/azurerm"

  managed_identities = {
    system_assigned = true
  }

  name                          = module.naming.container_app.name_unique
  location                      = module.regions.regions[random_integer.region_index.result].name
  cicd_system                   = "GitHub"
  pat_token_value               = var.personal_access_token
  container_image_name          = "microsoftavm/github-runner:1.0.1"
  subnet_address_prefix         = "10.0.2.0/23"
  virtual_network_address_space = "10.0.0.0/16"

  github_keda_metadata = {
    owner       = "BlakeWills-BJSS"
    runnerScope = "repo"
    repos       = join(",", ["terraform-azurerm-avm-ptn-cicd-agents-and-runners"])
  }

  pat_env_var_name = "GH_RUNNER_TOKEN"
  environment_variables = [
    {
      name  = "GH_RUNNER_URL",
      value = "https://github.com/BlakeWills-BJSS/terraform-azurerm-avm-ptn-cicd-agents-and-runners"
    },
    {
      name  = "GH_RUNNER_NAME"
      value = "container-app-agent"
    }
  ]

  enable_telemetry = true
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

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_personal_access_token"></a> [personal\_access\_token](#input\_personal\_access\_token)

Description: The personal access token used for agent authentication to Azure DevOps.

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm-ptn-cicd-agents-and-runners-ca"></a> [avm-ptn-cicd-agents-and-runners-ca](#module\_avm-ptn-cicd-agents-and-runners-ca)

Source: ../..

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