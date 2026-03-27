variable "name" {
  description = "Name for the Lightsail container service"
  type        = string
}

variable "power" {
  description = "Power (size) of the container service. Valid values: nano, micro, small, medium, large, xlarge"
  type        = string
  default     = "nano"

  validation {
    condition     = contains(["nano", "micro", "small", "medium", "large", "xlarge"], var.power)
    error_message = "power must be one of: nano, micro, small, medium, large, xlarge."
  }
}

variable "scale" {
  description = "Number of container service nodes to run (1–20)"
  type        = number
  default     = 1

  validation {
    condition     = var.scale >= 1 && var.scale <= 20
    error_message = "scale must be between 1 and 20."
  }
}

variable "is_disabled" {
  description = "Whether to disable the container service"
  type        = bool
  default     = false
}

variable "ecr_repository_name" {
  description = "Short name of the ECR repository (not the URL) to grant pull access to"
  type        = string
}

variable "default_tags" {
  type = map(any)
}

variable "tags" {
  type    = map(any)
  default = {}
}
