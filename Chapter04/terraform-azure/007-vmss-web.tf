# Create the azurecaf_name resources, which generates a unique name for an Azure resource of a specified type
resource "azurecaf_name" "web_vmss" {
  name          = var.name
  resource_type = "azurerm_linux_virtual_machine_scale_set"
  suffixes      = ["web", var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

resource "azurecaf_name" "web_vmss_nic" {
  name          = var.name
  resource_type = "azurerm_network_interface"
  suffixes      = ["web", var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

# Create the Azure Virtual Machine Scale Set for the web servers using a trimmed down version of the cloud-init script
resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                            = azurecaf_name.web_vmss.result
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  sku                             = var.vm_size
  instances                       = var.number_of_web_servers
  admin_username                  = var.vm_admin_username
  admin_password                  = random_password.vm_admin_password.result
  disable_password_authentication = false
  overprovision                   = false
  tags                            = var.default_tags

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = azurecaf_name.web_vmss_nic.result
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vnet_subnets["${var.subnet_for_vms}"].id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.load_balancer.id
      ]
    }
  }

  user_data = base64encode(templatefile("vmss-cloud-init-web.tftpl", {
    tmpl_file_share = "${azurerm_storage_account.sa.name}.file.core.windows.net:/${azurerm_storage_account.sa.name}/${azurerm_storage_share.nfs_share.name}"
  }))

  depends_on = [
    azurerm_linux_virtual_machine.admin_vm,
    azurerm_network_interface_backend_address_pool_association.admin_vm
  ]

}
