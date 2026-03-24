terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags = merge(var.tags, var.default_tags)
}

resource "aws_lightsail_database" "default" {
  relational_database_name = var.name
  blueprint_id             = var.blueprint_id
  bundle_id                = var.bundle_id

  master_database_name = var.master_database_name
  master_username      = var.master_username
  master_password      = var.master_password

  availability_zone          = var.availability_zone
  publicly_accessible        = var.publicly_accessible
  backup_retention_enabled   = var.backup_retention_enabled
  preferred_backup_window    = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately          = var.apply_immediately
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_name        = var.skip_final_snapshot ? null : var.final_snapshot_name

  tags = local.tags
}
