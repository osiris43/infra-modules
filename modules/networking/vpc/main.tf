terraform {
  required_version = ">= 1.5.0"
}

locals {
  tags = merge(var.default_tags, var.tags)
}
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_blocks

  tags = merge(local.tags, { Name = "${var.env}-${var.name}" })
}
