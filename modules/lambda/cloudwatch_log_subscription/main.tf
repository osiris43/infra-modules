resource "aws_lambda_permission" "allow_cloudwatch_log" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = "${var.log_group_arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "log_group_trigger" {
  count = var.enabled ? 1 : 0

  name            = "${var.lambda_name}-log-subscription"
  log_group_name  = var.log_group_name
  filter_pattern  = ""
  destination_arn = var.lambda_arn

  depends_on = [aws_lambda_permission.allow_cloudwatch_log]
}
