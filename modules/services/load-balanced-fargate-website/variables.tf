variable "region" {
  description = "which aws region to use"
  type        = string
}

variable "aws_account_id" {
  description = "The AWS Account ID to deploy the resources to"
  type        = string
}

variable "default_tags" {
  type = map(any)
}

variable "service_name" {
  description = "Name for your service"
  type        = string
}

variable "vpc_id" {
  dedescription = "VPC to place the service in"
  type          = string
}

variable "container_port" {
  type        = string
  description = "port to expose on the containers"
}

# OPTIONAL
variable "tags" {
  type        = map(any)
  description = "tags for this resource"
  default     = {}
}
