# Create the azurecaf_name resources, which generates a unique name for an Azure resource of a specified type

resource "azurecaf_name" "admin_vm" {
  name          = var.name
  resource_type = "azurerm_linux_virtual_machine"
  suffixes      = ["admin", var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

resource "azurecaf_name" "admin_vm_nic" {
  name          = var.name
  resource_type = "azurerm_network_interface"
  suffixes      = ["admin", var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

# Create the network interface for the admin VM
resource "azurerm_network_interface" "admin_vm" {
  name                = azurecaf_name.admin_vm_nic.result
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  tags                = var.default_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet_subnets["${var.subnet_for_vms}"].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Random password for Wordpress admin account
resource "random_password" "wordpress_admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Random password for virtual machines
resource "random_password" "vm_admin_password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  numeric          = true
  special          = true
  override_special = "!@#$%&"
}

# Launch the admin VM resource
resource "azurerm_linux_virtual_machine" "admin_vm" {
  name                            = azurecaf_name.admin_vm.result
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  admin_password                  = random_password.vm_admin_password.result
  disable_password_authentication = false
  tags                            = var.default_tags

  network_interface_ids = [
    azurerm_network_interface.admin_vm.id,
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

  user_data = base64encode(templatefile("vm-cloud-init-admin.yml.tftpl", {
    tmpl_database_username = "${var.database_administrator_login}"
    tmpl_database_password = "${random_password.database_admin_password.result}"
    tmpl_database_hostname = "${azurecaf_name.mysql_flexible_server.result}.${replace(var.name, "-", "")}.mysql.database.azure.com"
    tmpl_database_name     = "${azurerm_mysql_flexible_database.wordpress_database.name}"
    tmpl_file_share        = "${azurerm_storage_account.sa.name}.file.core.windows.net:/${azurerm_storage_account.sa.name}/${azurerm_storage_share.nfs_share.name}"
    tmpl_wordpress_url     = "http://${azurerm_public_ip.load_balancer.ip_address}"
    tmpl_wp_title          = "${var.wp_title}"
    tmpl_wp_admin_user     = "${var.wp_admin_user}"
    tmpl_wp_admin_password = "${random_password.wordpress_admin_password.result}"
    tmpl_wp_admin_email    = "${var.wp_admin_email}"
  }))
}

# Associate the admin VM with the load balancer
resource "azurerm_network_interface_backend_address_pool_association" "admin_vm" {
  network_interface_id    = azurerm_network_interface.admin_vm.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.load_balancer.id
}
