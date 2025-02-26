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

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "zip_dir" {
  description = "The zipped source code for the lambda to execute. If one is not provided, the default lambda will be deployed"
  type        = string
  default     = null
}

variable "handler" {
  description = "The fully qualified handler for the lambda to invoke"
  type        = string
  default     = "default-lambda::default_lambda.Function::FunctionHandler"
}

variable "runtime" {
  type    = string
  default = "dotnet8"
}

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

variable "enable_event_bridge" {
  description = "Whether or not to enable a cloud watch event to trigger lambda automatically"
  type        = bool
  default     = true
}


variable "cron_expression" {
  description = "The cron expression to trigger the lambda automatically. Default is every 10 mins every day"
  type        = string
  default     = "0/10 * ? * * *"
}

variable "event_input" {
  description = "The valid JSON for the cloud watch event to send to the lambda"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "s3_notification" {
  description = "Variables for the s3 notification"
  type = object({
    enabled       = bool
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
    bucket_arn    = string
    bucket_id     = string
  })
  default = {
    enabled       = false
    events        = [""]
    filter_prefix = null
    filter_suffix = null
    bucket_arn    = ""
    bucket_id     = ""
  }
}

variable "cloudwatch_log_subscription" {
  description = "Variables for the cloudwatch log group subscription"
  type = object({
    enabled                  = bool
    log_group_name           = string
    log_group_arn            = string
    log_group_filter_pattern = optional(string)
  })
  default = {
    enabled                  = false
    log_group_name           = ""
    log_group_arn            = ""
    log_group_filter_pattern = ""
  }
}
