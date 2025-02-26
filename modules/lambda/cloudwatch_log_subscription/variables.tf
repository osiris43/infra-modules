# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters, they should be provided by the parent terragrunt config
# ---------------------------------------------------------------------------------------------------------------------
variable "enabled" {
  type    = bool
  default = false
}

variable "region" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "log_group_arn" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "log_group_filter_pattern" {
  type    = string
  default = ""
}
