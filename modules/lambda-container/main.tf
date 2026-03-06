terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
  required_providers {
    aws = {
      configuration_aliases = [aws.datacenter]
    }
  }
}

locals {
  lambda_role_name           = "${var.function_name}-lambda-role"
  cloudwatch_event_rule_name = "${var.function_name}-schedule"
  datacenter_account_id      = data.aws_caller_identity.datacenter.account_id
  image_uri                  = "${local.datacenter_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository}:latest"
  tags                       = merge(var.default_tags, var.tags)
}

data "aws_caller_identity" "datacenter" {
  provider = aws.datacenter
}

module "iam_role" {
  source = "./iam_role"

  name         = local.lambda_role_name
  iam_policies = var.iam_policies
  tags         = local.tags
}

resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  role          = module.iam_role.role_arn
  image_uri     = local.image_uri
  timeout       = var.timeout
  memory_size   = var.memory_size
  package_type  = "Image"

  lifecycle {
    ignore_changes = [handler, environment]
  }

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  tags = local.tags
}
