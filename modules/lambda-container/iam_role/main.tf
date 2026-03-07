resource "aws_iam_role" "lambda" {
  name = var.name
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.name}-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:AssociateKmsKey"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.iam_policies

    content {
      actions   = statement.value.Actions
      resources = statement.value.Resources
      effect    = statement.value.Effect
      sid       = statement.key
    }
  }
}
