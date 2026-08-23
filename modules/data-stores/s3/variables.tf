# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "bucket_name" {
  description = "The name of the s3 bucket"
  type        = string
}

variable "default_tags" {
  type = map(any)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

variable "ip_whitelist" {
  description = "Adds a bucket policy statement that denies all S3 actions from IPs not in this list"
  type        = list(string)
  default     = []
}

variable "custom_policies" {
  description = "map of custom policies to apply to the bucket"
  type = map(object({
    Actions   = list(string),
    Effect    = string,
    Resources = list(string)
    Principal = optional(object({
      Type        = string,
      Identifiers = list(string)
    }))
    NotPrincipal = optional(object({
      Type        = string,
      Identifiers = list(string)
    }))
    Condition = optional(object({
      Test     = string,
      Variable = string,
      Values   = list(string)
    }))
  }))
  default = {}
}

variable "encryption_type" {
  description = "type of server side encryption, defaults to aws:kms"
  type        = string
  default     = "aws:kms"
  validation {
    condition     = var.encryption_type == "AES256" || var.encryption_type == "aws:kms"
    error_message = "The encryption type must be either AES256 or aws:kms"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
variable "lifecycle_configuration" {
  description = "Map of lifecycle configurations to apply to the bucket"
  type = map(object({
    # (Required) Lifecycle rule status: \"Enabled\" or \"Disabled\"
    status = string

    # (Optional) Filter identifying objects to which the rule applies.
    # Example: { prefix = "SomeFolder/" }
    filter = optional(object({
      prefix = string
    }))

    # (Optional) Current object expiration
    # Example: { days = 14 }
    expiration = optional(object({
      days = number
    }))

    # (Optional) Noncurrent version expiration (for versioned buckets)
    # Example: { noncurrent_days = 14 }
    noncurrent_version_expiration = optional(object({
      noncurrent_days           = number
      newer_noncurrent_versions = optional(number)
    }))

    # (Optional) Abort incomplete multipart uploads
    # Example: { days_after_initiation = 7 }
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))
  default = {}
}

variable "bucket_ownership" {
  description = "Ownership of the items written to the bucket"
  type        = string
  default     = "ObjectWriter"
  validation {
    condition     = contains(["BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"], var.bucket_ownership)
    error_message = "Object ownership. Must be one of `BucketOwnerPreferred`, `ObjectWriter`, or `BucketOwnerEnforced`."
  }
}


variable "tags" {
  type    = map(any)
  default = {}
}

variable "object_lock_configuration" {
  description = "Object Lock default retention configuration for the bucket. Enables Object Lock when provided."
  type = object({
    # Object Lock retention mode: GOVERNANCE or COMPLIANCE
    mode = string
    # Retention period - specify either days or years, not both
    days  = optional(number)
    years = optional(number)
  })
  default = null
  validation {
    condition = (
      var.object_lock_configuration == null ? true :
      contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_configuration.mode)
    )
    error_message = "Object Lock mode must be either GOVERNANCE or COMPLIANCE."
  }
  validation {
    condition = (
      var.object_lock_configuration == null ? true :
      (var.object_lock_configuration.days != null || var.object_lock_configuration.years != null)
    )
    error_message = "Object Lock configuration must specify either days or years."
  }
  validation {
    condition = (
      var.object_lock_configuration == null ? true :
      !(var.object_lock_configuration.days != null && var.object_lock_configuration.years != null)
    )
    error_message = "Object Lock configuration cannot specify both days and years."
  }
}

variable "cors_rules" {
  description = "Map of CORS rules to apply to the bucket"
  type = map(object({
    allowed_methods = list(string)           # (Required) e.g. ["GET", "PUT", "POST"]
    allowed_origins = list(string)           # (Required) e.g. ["https://example.com"]
    allowed_headers = optional(list(string)) # (Optional) e.g. ["*"]
    expose_headers  = optional(list(string)) # (Optional) e.g. ["ETag"]
    max_age_seconds = optional(number)       # (Optional) e.g. 3000
  }))
  default = {}
}

variable "enable_eventbridge" {
  description = "Enable EventBridge notifications for this bucket"
  type        = bool
  default     = false
}

variable "bucket_acl" {
  description = "Canned ACL type. Should be one of the following `private`, `public-read`, `public-read-write`, or `log-delivery-write`"
  type        = string
  default     = "private"
}

variable "enabled_versioning" {
  description = "True or False to control the versioning of the bucket"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "JSON document of the bucket policy. Use this parameter or pass in `custom_policies`"
  type        = string
  default     = ""
}
