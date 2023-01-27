# Initialize Terraform and the Azure Providers
terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
      version = "~>3.0"
    }
    azurecaf = {
      source = "aztfmod/azurecaf" # https://registry.terraform.io/providers/aztfmod/azurecaf/latest
    }
    random = {
      source = "hashicorp/random" # https://registry.terraform.io/providers/hashicorp/random/latest
    }
    http = {
      source = "hashicorp/http" # https://registry.terraform.io/providers/hashicorp/http/latest
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Use the the Azure Region module to get the short name of the Azure region for more
# details see: https://registry.terraform.io/modules/claranet/regions/azurerm/latest 
module "azure_region" {
  source       = "claranet/regions/azurerm"
  azure_region = var.location
}
