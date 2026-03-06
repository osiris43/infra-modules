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
  description = "the environment name [dev, stage, prod]"
  type        = string
}

variable "function_name" {
  description = "the name of the function"
  type        = string
}

variable "default_tags" {
  type = map(any)
}

variable "ecr_repository" {
  description = "ECR Repository for the image"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "iam_policies" {
  description = "Any custom actions your lambda should have access to (e.g. s3, kms, dynamo)"
  type = map(object({
    Actions   = list(string),
    Effect    = string,
    Resources = list(string)
  }))
  default = null
}

variable "tags" {
  type    = map(any)
  default = {}
}
