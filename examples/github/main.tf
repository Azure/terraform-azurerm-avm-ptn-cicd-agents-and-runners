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