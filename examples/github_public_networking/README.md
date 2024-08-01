<!-- BEGIN_TF_DOCS -->
# GitHub minimal example

This example deploys GitHub Runners to Azure Container Apps using the minimal set of required variables.

```hcl
variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}

variable "github_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to GitHub."
  sensitive   = true
}

variable "github_runners_personal_access_token" {
  description = "Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire)."
  type        = string
  sensitive   = true
}

locals {
  tags = {
    scenario = "default"
  }
}

terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  token = var.github_personal_access_token
  owner = var.github_organization_name
}

module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

resource "random_string" "name" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

data "github_organization" "alz" {
  name = var.github_organization_name
}

locals {
  enterprise_plan = "enterprise"
  free_plan       = "free"
}

resource "github_repository" "alz" {
  name                 = random_string.name.result
  description          = random_string.name.result
  auto_init            = true
  visibility           = data.github_organization.alz.plan == local.free_plan ? "public" : "private"
  allow_update_branch  = true
  allow_merge_commit   = false
  allow_rebase_merge   = false
  vulnerability_alerts = true
}

# This is the module call
module "github_runners" {
  source                                       = "../.."
  postfix                                      = random_string.name.result
  location                                     = module.regions.regions[random_integer.region_index.result].name
  version_control_system_type                  = "github"
  version_control_system_personal_access_token = var.github_runners_personal_access_token
  version_control_system_organization          = var.github_organization_name
  version_control_system_repository            = github_repository.alz.name
  virtual_network_address_space                = "10.0.0.0/16"
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.113)

- <a name="requirement_github"></a> [github](#requirement\_github) (~> 5.36)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [github_repository.alz](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [github_organization.alz](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/organization) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_github_organization_name"></a> [github\_organization\_name](#input\_github\_organization\_name)

Description: GitHub Organisation Name

Type: `string`

### <a name="input_github_personal_access_token"></a> [github\_personal\_access\_token](#input\_github\_personal\_access\_token)

Description: The personal access token used for authentication to GitHub.

Type: `string`

### <a name="input_github_runners_personal_access_token"></a> [github\_runners\_personal\_access\_token](#input\_github\_runners\_personal\_access\_token)

Description: Personal access token for GitHub self-hosted runners (the token requires the 'repo' scope and should not expire).

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_github_runners"></a> [github\_runners](#module\_github\_runners)

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