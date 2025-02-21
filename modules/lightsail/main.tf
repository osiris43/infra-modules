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

data "aws_iam_policy_document" "default" {
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
  repository = var.ecr_repository
  policy     = data.aws_iam_policy_document.default.json
}

resource "aws_lightsail_container_service_deployment_version" "example" {
  container {
    container_name = var.name
    image          = "${var.ecr_repository}:${var.image_version}"

    command = ["gunicorn", "-w", "4", "-b", "0.0.0.0:5050", "tyche:app"]

    environment = {
      FLASK_RUN_PORT = var.container_port
    }

    ports = {
      80 = "HTTP"
    }
  }

  public_endpoint {
    container_name = var.name
    container_port = var.container_port

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.default.name
}
