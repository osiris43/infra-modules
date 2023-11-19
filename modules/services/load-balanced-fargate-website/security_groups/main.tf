locals {
  alb_name  = "${var.env}-${var.name}-alb-sg"
  task_name = "${var.env}-${var.name}-ecs-task-sg"
}

resource "aws_security_group" "alb" {
  name        = local.alb_name
  description = "ALB security group for ${local.alb_name}"
  vpc_id      = var.vpc_id

  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = local.alb_name }, var.tags)
}

resource "aws_security_group" "ecs_task" {
  name        = local.task_name
  description = "ECS Task security group for ${local.task_name}"
  vpc_id      = var.vpc_id

  ingress {
    to_port     = var.container_port
    from_port   = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = local.task_name }, var.tags)
}
