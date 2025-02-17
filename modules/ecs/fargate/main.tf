terraform {
  required_version = ">= 1.2.9"
  backend "s3" {}
}

locals {
  tags                  = merge(var.tags, var.default_tags)
  task_exec_secret_arns = [for key, value in var.secrets : value]
  log_group_name        = "/concord/${var.container_name}"
  datacenter_account_id = data.aws_caller_identity.datacenter.account_id
  container_image       = "${local.datacenter_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.container_name}:${var.container_version}"
  environment           = [for key, value in var.environment : { name = key, value = value }]
  datadog_environment   = [for key, value in var.datadog_environment : { name = key, value = value }]
  secrets               = [for key, value in var.secrets : { name = key, valueFrom = value }]
  datadog_secrets       = [for key, value in var.datadog_secrets : { name = key, valueFrom = value }]
  ecs_task_role_name    = var.tasks_iam_role_name != "" ? var.tasks_iam_role_name : "${var.service_name}-ecs-task-role"
  ecs_task_role_statements = [for policy_name, policy in var.tasks_iam_policies : {
    sid       = policy_name
    effect    = policy.Effect
    actions   = policy.Actions
    resources = policy.Resources
  }]
  alb_name    = "${var.service_name}-alb"
  ecs_sg_name = "${var.service_name}-ecs-sg"
}

data "aws_caller_identity" "datacenter" {
  provider = aws.datacenter
}

resource "aws_cloudwatch_log_group" "service_logs" {
  name              = local.log_group_name
  tags              = local.tags
  retention_in_days = var.log_group_retention_in_days
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.6.0"

  cluster_name = var.service_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.service_logs.name
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  task_exec_secret_arns = local.task_exec_secret_arns
  tags                  = local.tags
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.8.0"

  name                     = var.service_name
  cluster_arn              = module.ecs_cluster.arn
  desired_count            = var.desired_task_count
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity

  subnet_ids = var.private_subnet_ids

  create_tasks_iam_role          = var.create_tasks_iam_role
  tasks_iam_role_name            = local.ecs_task_role_name
  tasks_iam_role_statements      = local.ecs_task_role_statements
  tasks_iam_role_path            = var.tasks_iam_role_path
  tasks_iam_role_use_name_prefix = var.tasks_iam_role_use_name_prefix

  cpu    = var.task_cpu
  memory = var.task_memory

  enable_execute_command = var.enable_ecs_exec

  # This allows us to deploy initially via terraform and then later with another 
  # mechanism and not have terraform think config drift has happened.
  # I don't think this ever worked as designed when set to true. there was always drift. Defaulting to false now so deploys happen automagically.
  ignore_task_definition_changes = var.ignore_task_definition_changes
  force_new_deployment           = var.force_new_deployment

  container_definitions = {
    datadog-agent = {
      essential                = true
      image                    = var.datadog_agent_sidecar_image
      readonly_root_filesystem = false

      health_check = {
        command = ["CMD-SHELL", "agent health"]
      }

      port_mappings = [
        {
          containerPort = var.datadog_agent_sidecar_port_mappings.containerPort
          hostPort      = var.datadog_agent_sidecar_port_mappings.hostPort
          protocol      = var.datadog_agent_sidecar_port_mappings.protocol
        }
      ]

      environment = concat(
        local.datadog_environment, [
          {
            name  = "ECS_FARGATE"
            value = "true"
          },
          {
            name  = "DD_SITE"
            value = "us5.datadoghq.com"
          },
          {
            name  = "DD_ENV"
            value = var.env
          },
      ])

      secrets = local.datadog_secrets
    }
    (var.container_name) = {
      # Commented out for now as we run single container services.  The container
      # will default to the task level total above.
      # cpu       = 512
      # memory    = 1024
      essential                = true
      image                    = local.container_image
      readonly_root_filesystem = false

      health_check = {
        command = var.container_health_check_command
      }

      port_mappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      command    = var.command
      entryPoint = var.entryPoint

      enable_cloudwatch_logging = true
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "/ecs"
        }
      }

      environment = local.environment
      secrets     = local.secrets

    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["ex_ecs"].arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  security_group_use_name_prefix = false
  security_group_name            = local.ecs_sg_name
  security_group_description     = "Allows ${local.alb_name} Load Balancer access to ECS Service"
  security_group_tags            = { Name = local.ecs_sg_name }
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = var.lb_security_group
    }
    alb_ingress_443 = {
      type                     = "ingress"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Required for Secret manager access"
      source_security_group_id = var.lb_security_group
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.tags
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.2.0"

  name = local.alb_name

  enable_deletion_protection = var.enable_lb_deletion_protection
  load_balancer_type         = "application"

  vpc_id   = var.vpc_id
  subnets  = var.lb_is_internal ? var.private_subnet_ids : var.public_subnet_ids
  internal = var.lb_is_internal

  security_groups = [var.lb_security_group_ingress, var.lb_security_group]

  create_security_group = false

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = var.acm_certificate_arn

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = var.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = var.health_check_path
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.tags
}
