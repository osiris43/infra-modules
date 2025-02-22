# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "default_tags" {
  type = map(any)
}

variable "iam_policy_name" {
  description = "The name of the IAM Policy"
  type        = string
}

variable "name" {
  description = "The name of your IAM Policy"
  type        = string
}

variable "iam_policies" {
  description = "Policies to apply"
  type = map(object({
    Actions   = list(string),
    Effect    = string,
    Resources = list(string)
  }))
  default = null
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "tags" {
  type    = map(any)
  default = {}
}

variable "name_prefix" {
  description = "IAM policy name prefix"
  type        = string
  default     = null
}

variable "path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "description" {
  description = "The description of the policy"
  type        = string
  default     = null
}

variable "create_policy" {
  description = "Whether to create the IAM policy. Make this `false` if you just want the json doc out"
  type        = bool
  default     = true
}
