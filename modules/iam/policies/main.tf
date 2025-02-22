terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags = merge(var.default_tags, var.tags)
}

resource "aws_iam_policy" "this" {
  count = var.create_policy ? 1 : 0

  name        = var.name
  name_prefix = var.name_prefix
  path        = var.path
  description = var.description

  policy = data.aws_iam_policy_document.policy_doc.json

  tags = var.tags
}

data "aws_iam_policy_document" "policy_doc" {
  dynamic "statement" {
    for_each = var.iam_policies
    content {
      sid       = statement.key
      actions   = statement.value.Actions
      resources = statement.value.Resources
      effect    = statement.value.Effect
      dynamic "principals" {
        for_each = lookup(statement.value, "Principal", null) != null ? [statement.value.Principal] : []
        content {
          type        = principals.value.Type
          identifiers = principals.value.Identifiers
        }
      }
      dynamic "not_principals" {
        for_each = lookup(statement.value, "NotPrincipal", null) != null ? [statement.value.NotPrincipal] : []
        content {
          type        = not_principals.value.Type
          identifiers = not_principals.value.Identifiers
        }
      }
      dynamic "condition" {
        for_each = lookup(statement.value, "Condition", null) != null ? [statement.value.Condition] : []
        content {
          test     = condition.value.Test
          variable = condition.value.Variable
          values   = condition.value.Values
        }
      }
    }
  }
}
