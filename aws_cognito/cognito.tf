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

variable "facebook_provider_client_id" {
  type = string
  description = "The client ID for the Facebook provider"
  default = "facebook_provider_client_id"
}

variable "facebook_provider_client_secret" {
  type = string
  description = "The client secret for the Facebook provider"
  default = "facebook_provider_client_secret"
}

variable "google_provider_client_id" {
  type = string
  description = "The client ID for the Google provider"
  default = "google_provider_client_id"
}

variable "google_provider_client_secret" {
  type = string
  description = "The client secret for the Google provider"
  default = "google_provider_client_secret"
}

// Providers
provider "aws" {
  region  = var.aws_region
  profile = "makers3"
}

resource "aws_cognito_user_pool" "maker_test_pool" {
  name = "Test-pool"

  deletion_protection = "ACTIVE"

  # Step 1: Configure sign-in experience
  alias_attributes = ["email"]

  auto_verified_attributes = ["email"]

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  # User names are not case sensitive
  username_configuration {
    case_sensitive = false
  }

  # Step 2: Configure security requirements
  # Using Cognito's default password policy
  mfa_configuration = "OFF"

  # Configure admin create user settings and email verification message
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Step 4: Configure message delivery
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # Cognito will send emails for you
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }
}

resource "aws_cognito_user_pool_domain" "makers_test_domain" {
  domain       = "domain-makers-test"
  user_pool_id = aws_cognito_user_pool.maker_test_pool.id
}

resource "aws_cognito_identity_provider" "google_provider" {
  user_pool_id  = aws_cognito_user_pool.maker_test_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.google_provider_client_id
    client_secret    = var.google_provider_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_identity_provider" "facebook_provider"{
  user_pool_id  = aws_cognito_user_pool.maker_test_pool.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    authorize_scopes = "public_profile, email"
    client_id        = var.facebook_provider_client_id
    client_secret    = var.facebook_provider_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "id"
  }
}

resource "aws_cognito_user_pool_client" "makers_test_client" {
  name = "Test-client"
  user_pool_id = aws_cognito_user_pool.maker_test_pool.id
  generate_secret = false

  # Step 5: Integrate your app
  callback_urls = ["https://localhost:8000/auth/token_code"]
  logout_urls   = ["https://test-sign-out"]

  supported_identity_providers = ["COGNITO", "Facebook", "Google"]

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "phone"]
  allowed_oauth_flows_user_pool_client = true
}

# Note: Facebook and Google as identity providers require additional AWS Console configuration
