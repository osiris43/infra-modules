# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters, they should be provided by the parent terragrunt config
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name of your Event Bridge schedule"
  type        = string
}

variable "description" {
  type = string
}

variable "schedule" {
  description = "The cron expression for the schedule"
  type        = string
}

variable "lambda_arn" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "event_input" {
  description = "The JSON input for the cloudwatch event to send"
  type        = string
}

variable "enabled" {
  type = bool
}
