terraform {
  required_version = ">= 1.5.0"
}

locals {
  tags = merge(var.tags, var.default_tags)
}

module "security_groups" {
  source = "./security_groups"

  name           = var.service_name
  vpc_id         = var.vpc_id
  env            = var.env
  container_port = var.container_port
}

# resource "aws_ecs_cluster" "foo" {
#   name = "hello-world"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }

# resource "aws_ecs_task_definition" "test" {
#   family                   = "helloworld"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   #cpu                      = 1024
#   #memory                   = 2048
#   container_definitions = <<TASK_DEFINITION
# [
#   {
#     "name": "hello-world",
#     "image": "nginx:latest",
#     "cpu": 1024,
#     "memory": 2048,
#     "essential": true
#   }
# ]
# TASK_DEFINITION

# }

# resource "aws_ecs_service" "svc" {
#   name = var.service_name
# }
