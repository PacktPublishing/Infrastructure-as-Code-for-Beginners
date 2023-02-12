module "azure_region" {
  source       = "claranet/regions/azurerm"
  azure_region = var.region
}

module "rg" {
  source      = "claranet/rg/azurerm"
  location    = module.azure_region.location
  client_name = var.name
  environment = var.environment
  stack       = var.project_name
}

module "azure_virtual_network" {
  source              = "claranet/vnet/azurerm"
  environment         = var.environment
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  client_name         = var.name
  stack               = var.project_name
  resource_group_name = module.rg.resource_group_name
  vnet_cidr           = var.address_space
}

module "azure_network_subnet" {
  for_each             = var.subnets
  source               = "claranet/subnet/azurerm"
  environment          = var.environment
  location_short       = module.azure_region.location_short
  custom_subnet_name   = each.value.name
  client_name          = var.name
  stack                = var.project_name
  resource_group_name  = module.rg.resource_group_name
  virtual_network_name = module.azure_virtual_network.virtual_network_name
  subnet_cidr_list     = [cidrsubnet("${module.azure_virtual_network.virtual_network_space[0]}", each.value.address_prefix_size, each.value.address_prefix_number)]
}
