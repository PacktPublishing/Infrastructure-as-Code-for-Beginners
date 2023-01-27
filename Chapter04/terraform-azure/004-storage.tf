# Create the azurecaf_name resources, which generates a unique name for an Azure resource of a specified type
resource "azurecaf_name" "sa" {
  name          = var.name
  resource_type = "azurerm_storage_account"
  suffixes      = [var.environment_type, module.azure_region.location_short]
  random_length = 5
  clean_input   = true
}
resource "azurecaf_name" "sa_endpoint" {
  name          = azurecaf_name.sa.result
  resource_type = "azurerm_private_endpoint"
  clean_input   = true
}

# This block of code creates a resource of type "azurerm_storage_account", which represents an Azure Storage Account
resource "azurerm_storage_account" "sa" {
  name                      = azurecaf_name.sa.result
  resource_group_name       = azurerm_resource_group.resource_group.name
  location                  = azurerm_resource_group.resource_group.location
  account_tier              = var.sa_account_tier
  account_kind              = var.sa_account_kind
  account_replication_type  = var.sa_account_replication_type
  enable_https_traffic_only = var.sa_enable_https_traffic_only
  min_tls_version           = var.sa_min_tls_version
  tags                      = var.default_tags
}

# This block of code creates a resource of type "azurerm_storage_account_network_rules", which represents the network rules for an Azure Storage Account using the IP address of the current machine
resource "azurerm_storage_account_network_rules" "sa" {
  storage_account_id = azurerm_storage_account.sa.id
  default_action     = var.sa_network_default_action
  ip_rules           = setunion(var.network_trusted_ips, ["${jsondecode(data.http.current_ip.response_body).ip}"])
  bypass             = var.sa_network_bypass
  virtual_network_subnet_ids = [
    for subnet_id in azurerm_subnet.vnet_subnets :
    subnet_id.id
  ]
}

# This block of code creates a resource of type "azurerm_storage_share", which represents an Azure Storage Share
resource "azurerm_storage_share" "nfs_share" {
  name                 = replace(var.name, "-", "")
  storage_account_name = azurerm_storage_account.sa.name
  quota                = var.nfs_share_quota
  enabled_protocol     = var.nfs_enbled_protocol

  depends_on = [
    azurerm_storage_account_network_rules.sa
  ]
}

# This block of code creates a resource of type "azurerm_private_dns_zone", which represents a private DNS zone
resource "azurerm_private_dns_zone" "storage_share_private_zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.resource_group.name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_share_private_zone" {
  name                  = "link-${azurerm_virtual_network.vnet.name}"
  resource_group_name   = azurerm_resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_share_private_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
  tags                  = var.default_tags
}

# This block of code creates a resource of type "azurerm_private_endpoint", which represents a private endpoint
resource "azurerm_private_endpoint" "storage_share_endpoint" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  name                = azurecaf_name.sa_endpoint.result
  subnet_id           = azurerm_subnet.vnet_subnets["${var.subnet_for_endpoints}"].id
  tags                = var.default_tags

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_share_private_zone.id]
  }

  private_service_connection {
    name                           = azurerm_storage_account.sa.name
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}
