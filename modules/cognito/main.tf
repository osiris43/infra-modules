terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

data "aws_region" "current" {}

locals {
  tags = {
    app_name    = var.app_name
    environment = var.environment
  }

  identity_providers = concat(
    ["Google"],
    var.facebook_app_id != null ? ["Facebook"] : [],
    var.apple_services_id != null ? ["SignInWithApple"] : [],
  )
}

resource "aws_cognito_user_pool" "default" {
  name = "${var.app_name}-${var.environment}"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = local.tags
}

resource "aws_cognito_user_pool_domain" "default" {
  domain      = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.default.id
}

resource "aws_cognito_user_pool_client" "default" {
  name         = "${var.app_name}-${var.environment}-client"
  user_pool_id = aws_cognito_user_pool.default.id

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  supported_identity_providers = local.identity_providers

  token_validity_units {
    access_token  = "hours"
    refresh_token = "days"
  }

  access_token_validity  = 1
  refresh_token_validity = 30

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  generate_secret = false
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.default.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "email profile openid"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "sub"
  }

  depends_on = [aws_cognito_user_pool_client.default]
}

resource "aws_cognito_identity_provider" "facebook" {
  count = var.facebook_app_id != null ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.default.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    client_id        = var.facebook_app_id
    client_secret    = var.facebook_app_secret
    authorize_scopes = "email,public_profile"
    api_version      = "v17.0"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "id"
  }

  depends_on = [aws_cognito_user_pool_client.default]
}

resource "aws_cognito_identity_provider" "apple" {
  count = var.apple_services_id != null ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.default.id
  provider_name = "SignInWithApple"
  provider_type = "SignInWithApple"

  provider_details = {
    client_id        = var.apple_services_id
    team_id          = var.apple_team_id
    key_id           = var.apple_key_id
    private_key      = var.apple_private_key
    authorize_scopes = "email name"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "sub"
  }

  depends_on = [aws_cognito_user_pool_client.default]
}
