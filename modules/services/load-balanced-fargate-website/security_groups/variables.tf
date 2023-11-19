variable "name" {
  description = "The name of your stack"
  type        = string
}

variable "vpc_id" {
  description = "The VPC in which to deploy the service"
  type        = string
}

variable "env" {
  description = "Concord Environment"
  type        = string
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  type        = number
}

variable "tags" {
  type = map(any)
}
