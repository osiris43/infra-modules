variable "name" {
  description = "Name for the lightsail instance"
  type        = string
}

variable "power" {
  description = "Size for the lightsail instance"
  type        = string
  default     = "nano"
}

variable "scale" {
  description = "How many instances for the lightsail instance"
  type        = number
  default     = 1
}

variable "is_disabled" {
  description = "Is the instance disabled.  "
  type        = bool
  default     = false
}

variable "ecr_repository" {
  description = "Repository name for ECR to pull images from"
  type        = string
}

variable "default_tags" {
  type = map(any)
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "container_port" {
  description = "Port for the service"
  type        = number
  default     = 80
}

variable "image_version" {
  description = "image for the service"
  type        = string
  default     = "latest"
}

variable "environment" {
  description = "key value map of env vars"
  type        = map(any)
  default     = {}
}
