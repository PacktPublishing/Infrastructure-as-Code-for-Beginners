variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "iac-ansible"
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "The default tags to use across all of our resources"
  type        = map(any)
  default = {
    project     = "iac-ansible"
    environment = "prod"
    deployed_by = "terraform"
  }
}

variable "address_space" {
  description = "The address space of the network"
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnets" {
  description = "The subnets to deploy the network"
  type = map(object({
    name                  = string
    address_prefix_size   = number
    address_prefix_number = number
  }))
  default = {
    subnet_001 = {
      name                  = "subnet001"
      address_prefix_size   = "3"
      address_prefix_number = "0"
    },
  }
}

variable "subnet_for_vms" {
  description = "Reference to put the virtual machines in"
  default     = "subnet_001"
}

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

variable "vm_ssh_public_key" {
  description = "The public ssh key"
  type        = string
  default     = "some ssh key here  - this is not a valid key"
}