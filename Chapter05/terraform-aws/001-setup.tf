# Initialize Terraform and the AWS Providers
terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # https://registry.terraform.io/providers/hashicorp/aws/latest
      version = "~> 4.0"
    }
    random = {
      source = "hashicorp/random" # https://registry.terraform.io/providers/hashicorp/random/latest
    }
    http = {
      source = "hashicorp/http" # https://registry.terraform.io/providers/hashicorp/http/latest
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
