terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  lambda_role_name           = "${var.function_name}-lambda-role"
  cloudwatch_event_rule_name = "${var.function_name}-schedule"
  lambda_zip_file            = var.zip_dir == null ? "${path.module}/default_lambda.zip" : var.zip_dir
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

module "s3_notification" {
  source = "./s3_notification"

  enabled       = var.s3_notification.enabled
  lambda_name   = aws_lambda_function.lambda.function_name
  lambda_arn    = aws_lambda_function.lambda.arn
  events        = var.s3_notification.events
  filter_prefix = var.s3_notification.filter_prefix
  filter_suffix = var.s3_notification.filter_suffix
  bucket_arn    = var.s3_notification.bucket_arn
  bucket_id     = var.s3_notification.bucket_id

  tags = local.tags
}

module "cloudwatch_log_subscription" {
  source = "./cloudwatch_log_subscription"

  enabled                  = var.cloudwatch_log_subscription.enabled
  lambda_name              = aws_lambda_function.lambda.function_name
  lambda_arn               = aws_lambda_function.lambda.arn
  log_group_name           = var.cloudwatch_log_subscription.log_group_name
  log_group_arn            = var.cloudwatch_log_subscription.log_group_arn
  log_group_filter_pattern = var.cloudwatch_log_subscription.log_group_filter_pattern
  region                   = var.region
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  filename         = local.lambda_zip_file
  role             = module.iam_role.role_arn
  handler          = var.handler
  source_code_hash = filebase64sha256(local.lambda_zip_file)

  runtime     = var.runtime
  timeout     = var.timeout
  memory_size = var.memory_size

  lifecycle {
    ignore_changes = [source_code_hash, handler, environment]
  }

  tags = local.tags
}
