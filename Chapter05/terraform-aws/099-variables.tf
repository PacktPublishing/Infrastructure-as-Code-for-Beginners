# Envionment Variables
######################################################################################################
variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "iac-wordpress"
}

variable "environment_type" {
  description = "type of the environment we are building"
  type        = string
  default     = "test"
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "zones" {
  description = "The AWS availability zone to deploy to"
  type        = list(any)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
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

variable "min_number_of_web_servers" {
  description = "How many web servers do we want to deploy"
  type        = number
  default     = 2
}

variable "max_number_of_web_servers" {
  description = "How many web servers do we want to deploy"
  type        = number
  default     = 4
}

variable "wp_title" {
  description = "The title of the Wordpress site"
  type        = string
  default     = "IAC Wordpress"
}

variable "wp_admin_user" {
  description = "The username for the Wordpress admin account"
  type        = string
  default     = "admin"
}

variable "wp_admin_email" {
  description = "The email address for the Wordpress admin account"
  type        = string
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

variable "vpc_address_space" {
  description = "The address space of vnet"
  type        = string
  default     = "10.0.0.0/24"
}

# Database Variables
######################################################################################################


variable "database_username" {
  description = "The username for the database"
  type        = string
  default     = "wordpress"
}

variable "database_name" {
  description = "The name of the database"
  type        = string
  default     = "wordpress"
}


variable "database_instance_class" {
  description = "The sku name for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "database_allocated_storage" {
  description = "The allocated storage for the database"
  type        = number
  default     = 5
}

variable "database_engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "database_engine_version" {
  description = "The database engine version to use"
  type        = string
  default     = "5.7"
}

variable "database_parameter_group" {
  description = "The database parameter group to use"
  type        = string
  default     = "default.mysql5.7"
}

variable "database_skip_final_snapshot" {
  description = "Should a final snapshot be created before the database is deleted"
  type        = bool
  default     = true
}

# Virtual Machine Variables
######################################################################################################

variable "instance_type" {
  description = "The size of the virtual machine"
  type        = string
  default     = "t2.micro"
}

