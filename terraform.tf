terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    modtm = {
      source  = "registry.terraform.io/azure/modtm"
      version = "~> 0.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}
