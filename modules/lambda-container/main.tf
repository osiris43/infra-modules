terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  lambda_role_name           = "${var.function_name}-lambda-role"
  cloudwatch_event_rule_name = "${var.function_name}-schedule"
  image_uri                  = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository}:latest"
  tags                       = merge(var.default_tags, var.tags)
}

module "iam_role" {
  source = "./iam_role"

  name         = local.lambda_role_name
  iam_policies = var.iam_policies
  tags         = local.tags
}

module "event_bridge" {
  source = "./event_bridge"

  enabled     = var.enable_event_bridge
  name        = local.cloudwatch_event_rule_name
  description = "Schedule for ${var.function_name}"
  schedule    = "cron(${var.cron_expression})"
  event_input = var.event_input

  lambda_arn  = aws_lambda_function.lambda.arn
  lambda_name = var.function_name

  tags = local.tags
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
