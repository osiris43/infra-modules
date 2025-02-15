# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  description = "The AWS region things are created in"
}

variable "aws_account_id" {
  description = "The AWS Account ID to deploy the resources to"
  type        = string
}

variable "env" {
  description = "Environment"
}

variable "name" {
  description = "The name of the keypair"
  type        = string
}

variable "default_tags" {
  description = "Default tags should be passed in from root terragrunt module (e.g. env, account, region, etc)"
  type        = map(any)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "algorithm" {
  description = "The algorithm used to generate the key"
  type        = string
  default     = "RSA"
}

variable "filename" {
  description = "The filename in which to store the ky locally"
  type        = string
  default     = "mykey.pem"
}

variable "file_permission" {
  description = "The numeric representation of the file permission"
  type        = number
  default     = 400
}

variable "tags" {
  type    = map(any)
  default = {}
}
