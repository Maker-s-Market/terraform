module "aws_ecs" {
    source = "./aws_ECS"
}

/*
module "aws_bucket" {
    source = "./aws_bucket"
}

module "aws_cognito" {
    source = "./aws_cognito"
}

module "aws_database" {
    source = "./aws_database"
}

module "aws_vpc" {
    source = "./aws_vpc"
} */

variable "MYSQL_ROOT_PASSWORD" {
  type        = string
  default     = "MYSQL_ROOT_PASSWORD"
}

variable "MYSQL_DATABASE" {
  type        = string
  default     = "MYSQL_DATABASE"
}

variable "MYSQL_USER" {
  type        = string
  default     = "MYSQL_USER"
}

variable "MYSQL_PASSWORD" {
  type        = string
  default     = "MYSQL_PASSWORD"
}

variable "MYSQL_HOST" {
  type        = string
  default     = "MYSQL_HOST"
}

variable "AWS_ACCESS_KEY_ID"{
  type        = string
  default     = "AWS_ACCESS_KEY_ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  default     = "AWS_SECRET_ACCESS_KEY"
}

variable "BUCKET_NAME" {
  type        = string
  default     = "BUCKET_NAME"
}

variable "USER_POOL_ID" {
  type        = string
  default     = "USER_POOL_ID"
}

variable "COGNITO_USER_CLIENT_ID" {
  type        = string
  default     = "COGNITO_USER_CLIENT_ID"
}

variable "COGNITO_DOMAIN" {
  type        = string
  default     = "COGNITO_DOMAIN"
}

variable "AUTH_URL" {
  type        = string
  default     = "https://COGNITO_DOMAIN/oauth2/authorize"
}

variable "TOKEN_URL" {
  type        = string
  default     = "https://COGNITO_DOMAIN/oauth2/token"
}

variable "LOGOUT_URL" {
  type        = string
  default     = "https://COGNITO_DOMAIN/logout"
}

// Variables
variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "makers3"
}
