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
  type = string
  description = "The region in which the resources will be created"
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc_id"
}

variable "private_subnet_1" {
  type    = string
  default = "private_subnet_1"
}

variable "private_subnet_2" {
  type    = string
  default = "private_subnet_2"
}

variable "db_identifier" {
  type = string
  default = "db_identifier"
}

variable "db_password" {
  type = string
  default = "db_password"
}

variable "ALB_security_group_id" {
  type = string
  default = "ALB_security_group_id"
}

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "makers5"
}

#create a security group for RDS Database Instance
resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  vpc_id = var.vpc_id
  # ingress {
  #   from_port       = 3306
  #   to_port         = 3306
  #   protocol        = "tcp"
  #   security_groups = [ var.ALB_security_group_id ]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [var.private_subnet_1, var.private_subnet_2]  # Specify your private subnet IDs

  tags = {
    Name = "My DB Subnet Group"
  }
}

#create a RDS Database Instance
resource "aws_db_instance" "myinstance" {
  engine               = "mysql"
  identifier           = var.db_identifier
  db_name              = var.db_identifier
  allocated_storage    =  20
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = var.db_identifier
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  skip_final_snapshot  = true
  publicly_accessible =  false
}

output "db_instance_endpoint" {
  value = aws_db_instance.myinstance.endpoint
}
