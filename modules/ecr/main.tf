terraform {
  required_version = ">= 1.5.0"
  backend "s3" {}
}
locals {
  tags = merge(var.default_tags, var.tags)
}

resource "aws_ecr_repository" "my_repo" {
  name = var.name
  tags = local.tags
}
