# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  description = "which aws region to use"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS Account ID to deploy the resources to"
  type        = string
}

variable "env" {
  description = "Concord Environment"
}

variable "user" {
  description = "The IAM User information"
  type = object({
    enable_console_access = bool
    full_name             = optional(string)
    username              = string
    email                 = optional(string)
  })
}

variable "groups" {
  description = "List of group names to add the user to"
  type        = list(string)
  default     = [""]
}

variable "default_tags" {
  description = "Default tags should be passed in from root terragrunt module (e.g. env, account, region, etc)"
  type        = map(any)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "tags" {
  type    = map(any)
  default = {}
}

variable "policy_arn" {
  type    = string
  default = ""
}
