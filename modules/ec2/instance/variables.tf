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
  description = "environment"
}

variable "default_tags" {
  type = map(any)
}

variable "name" {
  description = "Instance name"
  type        = string
}

variable "ami" {
  description = "AMI to use"
  type        = string
}

variable "ssh_key_name" {
  type        = string
  description = "The SSH Key Name"
}

variable "vpc_id" {
  type        = string
  description = "The VPC to deploy to."
}

variable "subnet_id" {
  type        = string
  description = "The subnet to deploy to."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "The existing VPC security groups to add this instance as a member to"
  default     = []
}

variable "default_sg" {
  description = <<EOF
    If this is set to true than a security group will be created for your instance.
      allow_ssh_from_cidr: The CIDR which to allow SSH from. Public will be IP or 0.0.0.0/0 and private will be public subnet CIDR
      allow_icmp_from_cidr: The CIDR which to allow ICMP from. Public will be IP or 0.0.0.0/0 and private will be public subnet CIDR
      allow_all_outbound_cidr: The CIDR to allow all outbound traffic from the ec2 instance
  EOF
  type = object({
    enabled                 = bool
    allow_ssh_from_cidr     = optional(string)
    allow_icmp_from_cidr    = optional(string)
    allow_all_outbound_cidr = optional(string)
  })
  default = {
    enabled = false
  }
}
variable "tags" {
  type    = map(any)
  default = {}
}
