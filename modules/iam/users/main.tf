terraform {
  required_version = ">= 1.2.9"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    pgp = {
      source = "ekristen/pgp"
    }
  }
  backend "s3" {}
}

locals {
  tags = merge(var.tags, var.default_tags)
}

resource "aws_iam_user" "user" {
  name = var.user.username
  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_user_policy_attachment" "policy_attach" {
  count      = var.policy_arn == "" ? 0 : 1
  user       = aws_iam_user.user.name
  policy_arn = var.policy_arn
}

resource "aws_iam_access_key" "user_access_key" {
  user       = var.user.username
  depends_on = [aws_iam_user.user]
}

resource "pgp_key" "user_login_key" {
  count = var.user.enable_console_access ? 1 : 0

  name    = var.user.full_name
  email   = var.user.email
  comment = "PGP Key for ${var.user.full_name}"
}

resource "aws_iam_user_login_profile" "user_login" {
  count = var.user.enable_console_access ? 1 : 0

  user                    = var.user.username
  pgp_key                 = pgp_key.user_login_key[0].public_key_base64
  password_reset_required = true

  depends_on = [aws_iam_user.user, pgp_key.user_login_key]

  lifecycle {
    ignore_changes = [pgp_key, password_reset_required, password_length]
  }
}

data "pgp_decrypt" "user_password_decrypt" {
  count = var.user.enable_console_access ? 1 : 0

  ciphertext          = aws_iam_user_login_profile.user_login[0].encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.user_login_key[0].private_key
}

resource "aws_iam_user_group_membership" "groups" {
  user   = aws_iam_user.user.name
  groups = var.groups
}
