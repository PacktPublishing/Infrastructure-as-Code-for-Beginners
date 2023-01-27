# Create the azurecaf_name resources, which generates a unique name for an Azure resource of a specified type
resource "azurecaf_name" "vnet" {
  name          = var.name
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

resource "azurecaf_name" "virtual_network_subnets" {
  for_each = var.vnet_subnets
  # Set the name variable to the subnet_name value in the current iteration of the for_each loop
  name          = each.value.subnet_name
  resource_type = "azurerm_subnet"
  suffixes      = [var.name, var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

resource "azurecaf_name" "load_balancer" {
  name          = var.name
  resource_type = "azurerm_lb"
  suffixes      = [var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

resource "azurecaf_name" "load_balancer_pip" {
  name          = azurecaf_name.load_balancer.result
  resource_type = "azurerm_public_ip"
  clean_input   = true
}

resource "azurecaf_name" "nsg" {
  name          = var.name
  resource_type = "azurerm_network_security_group"
  suffixes      = [var.environment_type, module.azure_region.location_short]
  clean_input   = true
}

# This block of code creates a resource of type "azurerm_virtual_network" and assigns it to the variable "vnet"
resource "azurerm_virtual_network" "vnet" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  name                = azurecaf_name.vnet.result
  address_space       = var.vnet_address_space
  tags                = var.default_tags
}

# Create an azurerm_subnet resource for each subnet in the virtual network using the vnet_subnets variable
resource "azurerm_subnet" "vnet_subnets" {
  # Iterate over the vnet_subnets variable
  for_each             = var.vnet_subnets
  name                 = azurecaf_name.virtual_network_subnets[each.key].result
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
  # Use the service endpoints from the vnet_subnets variable if they are provided, otherwise use an empty list
  service_endpoints = try(each.value.service_endpoints, [])
  # Use the private endpoint network policies enabled value from the vnet_subnets variable if it is provided, otherwise use an empty list
  private_endpoint_network_policies_enabled = try(each.value.private_endpoint_network_policies_enabled, [])
  # Iterate over the service delegations in the vnet_subnets variable
  dynamic "delegation" {
    for_each = each.value.service_delegations
    content {
      # Use the service delegation key as the name
      name = delegation.key
      # Iterate over the service delegation values
      dynamic "service_delegation" {
        for_each = delegation.value
        iterator = item
        content {
          # Use the service delegation value key as the name
          name = item.key
          # Use the service delegation value as the actions
          actions = item.value
        }
      }
    }
  }
}

# Create an azurerm_public_ip resource, which represents a public IP address in Azure which will be used for the load balancer
resource "azurerm_public_ip" "load_balancer" {
  name                = azurecaf_name.load_balancer_pip.result
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.default_tags
}


# Create an azurerm_lb resource, which represents an Azure load balancer
resource "azurerm_lb" "load_balancer" {
  name                = azurecaf_name.load_balancer.result
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Standard"
  tags                = var.default_tags

  # Create a frontend IP configuration using the public IP address from the azurerm_public_ip resource
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.load_balancer.id
  }
}

# Create an azurerm_lb_backend_address_pool resource, which represents a backend address pool for an Azure load balancer
resource "azurerm_lb_backend_address_pool" "load_balancer" {
  # Use the ID of the azurerm_lb resource as the load balancer ID
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "BackEndAddressPool"
}

# Create an azurerm_lb_probe resource, which represents a probe for an Azure load balancer
resource "azurerm_lb_probe" "http_load_balancer_probe" {
  # Use the ID of the azurerm_lb resource as the load balancer ID
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "http-running-probe"
  port            = 80
}

# Create an azurerm_lb_rule resource, which represents a rule for an Azure load balancer
resource "azurerm_lb_rule" "http_load_balancer_rule" {
  # Use the ID of the azurerm_lb resource as the load balancer ID
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "HTTPRule"
  protocol        = "Tcp"
  frontend_port   = 80
  backend_port    = 80
  # Use the ID of the azurerm_lb_probe resource as the probe ID
  probe_id = azurerm_lb_probe.http_load_balancer_probe.id
  # Use the name of the frontend IP configuration from the azurerm_lb resource
  frontend_ip_configuration_name = "PublicIPAddress"
  # Use the ID of the azurerm_lb_backend_address_pool resource as the backend address pool ID
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.load_balancer.id
  ]
}

# Create an azurerm_lb_nat_rule resource, which represents a NAT rule for an Azure load balancer
resource "azurerm_lb_nat_rule" "sshAccess" {
  # Use the resource group name from the azurerm_resource_group resource
  resource_group_name = azurerm_resource_group.resource_group.name
  # Use the ID of the azurerm_lb resource as the load balancer ID
  loadbalancer_id     = azurerm_lb.load_balancer.id
  name                = "sshAccess"
  protocol            = "Tcp"
  frontend_port_start = 2222
  frontend_port_end   = 2232
  backend_port        = 22
  # Use the ID of the azurerm_lb_backend_address_pool resource as the backend address pool ID
  backend_address_pool_id = azurerm_lb_backend_address_pool.load_balancer.id
  # Use the name of the frontend IP configuration from the azurerm_lb resource
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Create an azurerm_network_security_group resource, which represents an Azure Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  # Use the name generated by the azurecaf_name resource
  name = azurecaf_name.nsg.result
  # Use the resource group name and location from the azurerm_resource_group resource
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  tags                = var.default_tags
}

# Create an azurerm_network_security_rule resources, which represents a rule for an Azure Network Security Group (NSG)
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

# This block of code gets information on the public IP address of the current machine
data "http" "current_ip" {
  url = "https://api.ipify.org?format=json"
}

resource "azurerm_network_security_rule" "AllowSSH" {
  name        = "AllowSSH"
  description = "Allow SSH"
  priority    = 150
  direction   = "Inbound"
  access      = "Allow"
  protocol    = "Tcp"
  # Merge the list of trusted IPs from the var.network_trusted_ips variable and the current IP address
  source_address_prefixes     = setunion(var.network_trusted_ips, ["${jsondecode(data.http.current_ip.response_body).ip}"])
  source_port_range           = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


# Create an azurerm_subnet_network_security_group_association resource, which represents an association between a subnet and an Azure Network Security Group (NSG)
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  # Use the ID of the azurerm_subnet resource as the subnet_id
  subnet_id = azurerm_subnet.vnet_subnets["${var.subnet_for_vms}"].id
  # Use the ID of the azurerm_network_security_group resource as the network_security_group_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
