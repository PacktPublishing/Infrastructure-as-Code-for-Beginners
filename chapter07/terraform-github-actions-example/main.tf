terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "rg-${var.name}-${var.region}"
  location = var.region
  tags     = merge(var.tags, tomap({ Name = "rg-${var.name}-${var.region}" }))
}

resource "azurerm_virtual_network" "network" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  name                = "vnet-${var.name}-${var.region}"
  address_space       = [var.address_space]
  tags                = merge(var.tags, tomap({ Name = "vnet-${var.name}-${var.region}" }))
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [cidrsubnet("${azurerm_virtual_network.network.address_space[0]}", each.value.address_prefix_size, each.value.address_prefix_number)]
}
