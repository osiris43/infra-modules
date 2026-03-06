# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters, they should be provided by the parent terragrunt config
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name of your IAM Role"
  type        = string
}

variable "tags" {
  type = map(any)
}

variable "iam_policies" {
  type = map(object({
    Actions   = list(string),
    Effect    = string,
    Resources = list(string)
  }))
}
