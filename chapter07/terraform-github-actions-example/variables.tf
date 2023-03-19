variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "iac-github-actions"
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
    project     = "iac-github-actions"
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
    subnet_002 = {
      name                  = "subnet002"
      address_prefix_size   = "3"
      address_prefix_number = "1"
    },
    subnet_003 = {
      name                  = "subnet003"
      address_prefix_size   = "3"
      address_prefix_number = "2"
    },
    subnet_004 = {
      name                  = "subnet004"
      address_prefix_size   = "3"
      address_prefix_number = "3"
    },
  }
}
