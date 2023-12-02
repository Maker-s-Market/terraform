terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

provider "aws" {
  region  = var.aws_region
  profile = "makers3"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "makers-bucket-v3.5"

  tags = {
    Name = "Makers Bucket"
  }
}

resource "aws_s3_access_point" "my_access_point" {
  name   = "makers-access-point-v3-5"
  bucket = aws_s3_bucket.my_bucket.id

  vpc_configuration {
    vpc_id = "vpc-03c9139ceac689522"
  }
}


output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "access_point_arn" {
  value = aws_s3_access_point.my_access_point.arn
}
