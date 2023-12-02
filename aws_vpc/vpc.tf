terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

// Variables
variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks for the private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks for the public subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "terraform-user"
}

// VPC
resource "aws_vpc" "makers" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "makers-vpc"
  }
}

// Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.makers.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "makers-private${count.index + 1}"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.makers.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "makers-public${count.index + 1}"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "makers_igw" {
  vpc_id = aws_vpc.makers.id
  tags = {
    Name = "makers-igw"
  }
}

// NAT Gateway
resource "aws_nat_gateway" "makers_nat" {
  count               = length(var.public_subnet_cidr_blocks)
  subnet_id           = aws_subnet.public_subnets[count.index].id
  allocation_id       = aws_eip.nat_eip[count.index].id
  tags = {
    Name = "makers-nat${count.index + 1}"
  }
}

resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidr_blocks)
}

// Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.makers.id
  tags = {
    Name = "makers-public-rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.makers.id
  tags = {
    Name = "makers-private-rt"
  }
}

resource "aws_route" "private_route" {
  count              = length(var.private_subnet_cidr_blocks)
  route_table_id     = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id     = aws_nat_gateway.makers_nat[count.index].id
}
