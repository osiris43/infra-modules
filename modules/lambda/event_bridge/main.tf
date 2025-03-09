resource "aws_cloudwatch_event_rule" "schedule" {
  count = var.enabled ? 1 : 0

  name                = var.name
  description         = var.description
  schedule_expression = var.schedule

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
  count = var.enabled ? 1 : 0

  rule  = aws_cloudwatch_event_rule.schedule[0].name
  arn   = var.lambda_arn
  input = var.event_input
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}
