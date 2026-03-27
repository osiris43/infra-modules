terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags = merge(var.tags, var.default_tags)
}

resource "aws_lightsail_container_service" "default" {
  name        = var.name
  power       = var.power
  scale       = var.scale
  is_disabled = var.is_disabled

  tags = local.tags

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }
}

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_lightsail_container_service.default.private_registry_access[0].ecr_image_puller_role[0].principal_arn]
    }

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }
}

resource "aws_ecr_repository_policy" "default" {
  repository = var.ecr_repository_name
  policy     = data.aws_iam_policy_document.ecr_pull.json
}
