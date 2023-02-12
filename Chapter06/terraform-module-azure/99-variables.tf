variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "iac"
}

variable "project_name" {
  description = "Name of the project we are deploying"
  type        = string
  default     = "module"
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "The environment to deploy to"
  type        = string
  default     = "prod"
}

variable "address_space" {
  description = "The address space of the network"
  type        = list
  default     = ["10.0.0.0/24"]
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
