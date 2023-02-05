# Initialize Terraform and the AWS Providers
terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "network" {
  cidr_block           = var.address_space
  tags                 = merge(var.tags, tomap({ Name = "${var.name}-vpc" }))
}

resource "aws_subnet" "subnets" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.network.id
  cidr_block        = cidrsubnet("${aws_vpc.network.cidr_block}", each.value.address_prefix_size, each.value.address_prefix_number)
  tags              = merge(var.tags, tomap({ Name = "${var.name}-${each.value.name}" }))
}