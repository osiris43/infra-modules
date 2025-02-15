terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags = merge(var.tags, var.default_tags)
}

resource "tls_private_key" "my_key" {
  algorithm = var.algorithm
}

resource "local_file" "file" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = var.filename
  file_permission = var.file_permission
}

resource "aws_key_pair" "my_kp" {
  key_name   = var.name
  public_key = tls_private_key.my_key.public_key_openssh

  tags = local.tags
}
