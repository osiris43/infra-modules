terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags = merge(var.default_tags, var.tags)
}
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = local.tags
}

# Default AWS-managed key for S3, used when encryption_type is aws:kms
data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

# create the ACL for the bucket to be private
resource "aws_s3_bucket_acl" "bucket_acl" {
  for_each   = var.bucket_ownership != "BucketOwnerEnforced" ? toset(["apply"]) : []
  bucket     = aws_s3_bucket.bucket.id
  acl        = var.bucket_acl
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.bucket_ownership
  }
}

# enable versioning on the bucket
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.enabled_versioning ? "Enabled" : "Disabled"
  }
}

# enable server side encryption on the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.encryption_type == "aws:kms" ? data.aws_kms_alias.s3.arn : null
      sse_algorithm     = var.encryption_type
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

data "aws_iam_policy_document" "doc" {
  dynamic "statement" {
    for_each = var.custom_policies
    content {
      sid       = statement.key
      actions   = statement.value.Actions
      resources = statement.value.Resources
      effect    = statement.value.Effect
      dynamic "principals" {
        for_each = statement.value.Principal != null ? [statement.value.Principal] : []
        content {
          type        = principals.value.Type
          identifiers = principals.value.Identifiers
        }
      }
      dynamic "not_principals" {
        for_each = statement.value.NotPrincipal != null ? [statement.value.NotPrincipal] : []
        content {
          type        = not_principals.value.Type
          identifiers = not_principals.value.Identifiers
        }
      }
      dynamic "condition" {
        for_each = statement.value.Condition != null ? [statement.value.Condition] : []
        content {
          test     = condition.value.Test
          variable = condition.value.Variable
          values   = condition.value.Values
        }
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.ip_whitelist) > 0 ? ["apply"] : []
    content {
      sid    = "IPWhitelist"
      effect = "Deny"
      principals {
        type        = "*"
        identifiers = ["*"]
      }
      actions   = ["s3:*"]
      resources = [aws_s3_bucket.bucket.arn, "${aws_s3_bucket.bucket.arn}/*"]
      condition {
        test     = "NotIpAddress"
        variable = "aws:SourceIp"
        values   = var.ip_whitelist
      }
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = (var.bucket_policy != "" || length(var.custom_policies) > 0 || length(var.ip_whitelist) > 0) ? toset(["apply"]) : []
  bucket   = aws_s3_bucket.bucket.id

  policy = var.bucket_policy != "" ? var.bucket_policy : data.aws_iam_policy_document.doc.json

  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

resource "aws_s3_bucket_lifecycle_configuration" "l1" {
  for_each = length(var.lifecycle_configuration) > 0 ? toset(["apply"]) : []
  bucket   = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_configuration
    content {
      id     = rule.key
      status = rule.value.status
      # filter is required by the provider; an empty filter applies the rule to all objects
      filter {
        prefix = rule.value.filter == null ? null : rule.value.filter.prefix
      }
      dynamic "expiration" {
        for_each = rule.value.expiration == null ? [] : [rule.value.expiration]
        content {
          days = expiration.value.days
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration == null ? [] : [rule.value.noncurrent_version_expiration]
        content {
          noncurrent_days           = noncurrent_version_expiration.value.noncurrent_days
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(rule.value.abort_incomplete_multipart_upload, null) == null ? [] : [rule.value.abort_incomplete_multipart_upload]
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "object_lock" {
  for_each = var.object_lock_configuration != null ? toset(["apply"]) : []
  bucket   = aws_s3_bucket.bucket.id

  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = var.object_lock_configuration.days
      years = var.object_lock_configuration.years
    }
  }
}

resource "aws_s3_bucket_notification" "eventbridge" {
  for_each    = var.enable_eventbridge ? toset(["apply"]) : []
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  for_each = length(var.cors_rules) > 0 ? toset(["apply"]) : []
  bucket   = aws_s3_bucket.bucket.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      id              = cors_rule.key
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = cors_rule.value.allowed_headers
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}
