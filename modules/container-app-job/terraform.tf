terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
    }
  }
}
