terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

provider "azurerm" {
  features {}
}

module "azure_region" {
  source       = "claranet/regions/azurerm"
  azure_region = var.region
}

resource "azurerm_resource_group" "resource_group" {
  name     = "rg-${var.name}-${module.azure_region.location_short}"
  location = module.azure_region.location_cli
  tags     = merge(var.tags, tomap({ Name = "rg-${var.name}-${module.azure_region.location_short}" }))
}

resource "azurerm_virtual_network" "network" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  name                = "vnet-${var.name}-${module.azure_region.location_short}"
  address_space       = [var.address_space]
  tags                = merge(var.tags, tomap({ Name = "vnet-${var.name}-${module.azure_region.location_short}" }))
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [cidrsubnet("${azurerm_virtual_network.network.address_space[0]}", each.value.address_prefix_size, each.value.address_prefix_number)]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.name}-${module.azure_region.location_short}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  tags                = merge(var.tags, tomap({ Name = "nsg-${var.name}-${module.azure_region.location_short}" }))
}

data "http" "current_ip" {
  url = "https://api.ipify.org?format=json"
}

resource "azurerm_network_security_rule" "AllowHTTP" {
  name                        = "AllowHTTP"
  description                 = "Allow HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "AllowSSH" {
  name                        = "AllowSSH"
  description                 = "Allow SSH"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = [jsondecode(data.http.current_ip.response_body).ip]
  source_port_range           = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnets["${var.subnet_for_vms}"].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "pip-${var.name}-${module.azure_region.location_short}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = merge(var.tags, tomap({ Name = "pip-${var.name}-${module.azure_region.location_short}" }))
}

resource "azurerm_network_interface" "vm_network_interface" {
  name                = "nic-${var.name}-${module.azure_region.location_short}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  tags                = merge(var.tags, tomap({ Name = "nic-${var.name}-${module.azure_region.location_short}" }))

  ip_configuration {
    name                          = "vm-ip-configuration"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
    subnet_id                     = azurerm_subnet.subnets["${var.subnet_for_vms}"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                            = "vm-${var.name}-${module.azure_region.location_short}"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  disable_password_authentication = true
  tags                            = merge(var.tags, tomap({ Name = "vm-${var.name}-${module.azure_region.location_short}" }))


  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.vm_network_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.virtual_machine.name
}

output "vm_admin_username" {
  value = azurerm_linux_virtual_machine.virtual_machine.admin_username
}

output "public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}