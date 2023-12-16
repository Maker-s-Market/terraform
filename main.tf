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
// Variables
variable "aws_region" {
  type        = string
  description = "The region in which the resources will be created"
  default     = "us-east-1"
}

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

variable "MYSQL_SG" {
  type        = string
  default     = "MYSQL_SG"
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
  default     = "AUTH_URL"
}

variable "TOKEN_URL" {
  type        = string
  default     = "TOKEN_URL"
}

variable "LOGOUT_URL" {
  type        = string
  default     = "LOGOUT_URL"
}

variable "MAKERS_URL_API" {
  type        = string
  default     = "MAKERS_URL_API"
}

variable "FRONTEND_SIGN_UP_IDP_LINK" {
  type = string
  default = "FRONTEND_SIGN_UP_IDP_LINK"
}

variable "STRIPE_KEY" {
  type       = string
  default    = "STRIPE_KEY"
}

variable "API_KEY_EMAIL"{
  type       = string
  default    = "API_KEY_EMAIL"
}

variable "VITE_STRIPE_KEY"{
  type       = string
  default    = "VITE_STRIPE_KEY"
}

variable "VITE_GOOGLE_AUTH_URL"{
  type       = string
  default    = "VITE_GOOGLE_AUTH_URL"
}

variable "SSL_CERTIFICATE_ARN" {
  type        = string
  default     = "SSL_CERTIFICATE_ARN"
}

variable "VPC_ID" {
  type    = string
  default = "VPC_ID"
}

variable "PUBLIC_SUBNET_1" {
  type    = string
  default = "PUBLIC_SUBNET_1"
}

variable "PUBLIC_SUBNET_2" {
  type    = string
  default = "PUBLIC_SUBNET_2"
}

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "makers3"
}
