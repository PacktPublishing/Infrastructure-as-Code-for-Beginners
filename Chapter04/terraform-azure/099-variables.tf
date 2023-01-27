# Envionment Variables
######################################################################################################
variable "name" {
  description = "Base name for resources"
  default     = "iac-wordpress"
}

variable "location" {
  description = "Which region in Azure are we launching the resources"
  default     = "West Europe"
}

variable "environment_type" {
  description = "type of the environment we are building"
  default     = "prod"
}

variable "default_tags" {
  description = "The default tags to use across all of our resources"
  type        = map(any)
  default = {
    project     = "iac-wordpress"
    environment = "prod"
    deployed_by = "terraform"
  }
}

# Web Server and Wordpress Variables
######################################################################################################

variable "number_of_web_servers" {
  description = "How many web servers do we want to deploy"
  type        = number
  default     = 2
}

variable "wp_title" {
  description = "The title of the Wordpress site"
  default     = "IAC Wordpress"
}

variable "wp_admin_user" {
  description = "The username for the Wordpress admin account"
  default     = "admin"
}

variable "wp_admin_email" {
  description = "The email address for the Wordpress admin account"
  default     = "test@test.com"
}

# Networking Variables
######################################################################################################

variable "network_trusted_ips" {
  description = "Optional list if IP addresses which need access, your current IP will be added automatically"
  type        = list(any)
  default = [
  ]
}

variable "vnet_address_space" {
  description = "The address space of vnet"
  type        = list(any)
  default     = ["10.0.0.0/24"]
}

variable "vnet_subnets" {
  description = "The subnets to deploy in the vnet"
  type = map(object({
    subnet_name                               = string
    address_prefix                            = string
    private_endpoint_network_policies_enabled = bool
    service_endpoints                         = list(string)
    service_delegations                       = map(map(list(string)))
  }))
  default = {
    virtual_network_subnets_001 = {
      subnet_name                               = "vms"
      address_prefix                            = "10.0.0.0/27"
      private_endpoint_network_policies_enabled = true
      service_endpoints                         = ["Microsoft.Storage"]
      service_delegations                       = {}
    },
    virtual_network_subnets_002 = {
      subnet_name                               = "endpoints"
      address_prefix                            = "10.0.0.32/27"
      private_endpoint_network_policies_enabled = true
      service_endpoints                         = ["Microsoft.Storage"]
      service_delegations                       = {}
    },
    virtual_network_subnets_003 = {
      subnet_name                               = "database"
      address_prefix                            = "10.0.0.64/27"
      private_endpoint_network_policies_enabled = true
      service_endpoints                         = ["Microsoft.Storage"]
      service_delegations = {
        fs = {
          "Microsoft.DBforMySQL/flexibleServers" = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    },
  }
}

variable "subnet_for_vms" {
  description = "Reference to put the virtual machines in"
  default     = "virtual_network_subnets_001"
}
variable "subnet_for_endpoints" {
  description = "Reference to put the private endpoint in"
  default     = "virtual_network_subnets_002"
}

variable "subnet_for_database" {
  description = "Reference to put the database endpoint in"
  default     = "virtual_network_subnets_003"
}

# Storeage Variables
######################################################################################################

variable "sa_account_tier" {
  description = "What tier of storage account do we want to deploy"
  default     = "Premium"
}

variable "sa_account_kind" {
  description = "What kind of storage account do we want to deploy"
  default     = "FileStorage"
}

variable "sa_account_replication_type" {
  description = "What type of replication do we want to use"
  default     = "LRS"
}

variable "sa_enable_https_traffic_only" {
  description = "Do we want to enable https traffic only"
  type        = bool
  default     = false
}

variable "sa_min_tls_version" {
  description = "What is the minimum TLS version we want to use"
  default     = "TLS1_2"
}



variable "sa_network_bypass" {
  description = "Optional list if IP addresses which need access, your current IP will be added automatically"
  type        = list(any)
  default = [
    "Metrics",
    "Logging",
    "AzureServices",
  ]
}

variable "sa_network_default_action" {
  description = "What is the default action for the network rules"
  type        = string
  default     = "Deny"
}

variable "nfs_share_quota" {
  description = "The quota for the NFS share"
  type        = number
  default     = 100
}

variable "nfs_enbled_protocol" {
  description = "The protocol to use for the NFS share"
  type        = string
  default     = "NFS"
}

# Database Variables
######################################################################################################

variable "database_administrator_login" {
  description = "The admin user for the database"
  type        = string
  default     = "wordpress"
}

variable "database_backup_retention_days" {
  description = "The number of days to keep backups for"
  type        = number
  default     = 7
}

variable "database_sku_name" {
  description = "The sku name for the database"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "database_zone" {
  description = "The sku name for the database"
  type        = number
  default     = 1
}

variable "databaqse_charset" {
  description = "The charset for the database"
  type        = string
  default     = "utf8"
}

variable "database_collation" {
  description = "The collation for the database"
  type        = string
  default     = "utf8_general_ci"
}

# Virtual Machine Variables
######################################################################################################

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B1ms"
}

variable "vm_image_publisher" {
  description = "The publisher of the image"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "The offer of the image"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "vm_image_sku" {
  description = "The sku of the image"
  type        = string
  default     = "20_04-LTS"
}

variable "vm_image_version" {
  description = "The version of the image"
  type        = string
  default     = "latest"
}

variable "vm_admin_username" {
  description = "The admin user for the virtual machine"
  type        = string
  default     = "adminuser"
}

variable "vm_admin_ssh_key_path" {
  description = "The path to the ssh key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
