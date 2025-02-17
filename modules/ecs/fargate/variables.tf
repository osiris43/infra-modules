# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED APPLICATION SPECIFIC PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "vpc_id" {
  description = "The VPC in which to deploy the service"
  type        = string
}

variable "service_name" {
  description = "The name of your service"
  type        = string
}

variable "container_name" {
  description = "The name of your container"
  type        = string
}

variable "container_port" {
  description = "port for the container"
  type        = number
}

variable "container_version" {
  description = "version for the container"
  type        = string
}

variable "container_health_check_command" {
  description = "The container health check commands and associated configuration parameters"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "private subnet ids to deploy the service into"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "public subnet ids to deploy the service into"
  type        = list(string)
}

variable "lb_security_group_ingress" {
  description = "Security group for inbound access to load balancer"
  type        = string
}

variable "lb_security_group" {
  description = "Security group for load balancer to attach to"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "task_cpu" {
  description = "cpu for the task"
  type        = number
  default     = 1024
}

variable "task_memory" {
  description = "memory for the task"
  type        = number
  default     = 4096
}

variable "enable_lb_deletion_protection" {
  description = "If `true`, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to `true`"
  type        = bool
  default     = true
}

variable "lb_is_internal" {
  description = "(Optional) If true, the LB will be internal. Defaults to false"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path for the LB to perform health checks"
  type        = string
  default     = "/"
}

variable "log_group_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 10
}

variable "desired_task_count" {
  description = "Number of tasks you'd like to run"
  type        = number
  default     = 1
}

variable "autoscaling_min_capacity" {
  description = "The minimum capacity for autoscaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "The maximum capacity for autoscaling"
  type        = number
  default     = 10
}

variable "environment" {
  description = "The environment variables to pass to the container"
  type        = map(string)
  default     = {}
}

variable "enable_ecs_exec" {
  description = "If `true`, ECS Exec will be enabled for the service which allows executing arbitrary commands in a running container. Defaults to `false`."
  type        = bool
  default     = false
}

variable "secrets" {
  description = "The secrets to pass to the container."
  type        = map(string)
  default     = {}
}

variable "create_tasks_iam_role" {
  description = "Determines whether the ECS tasks IAM role should be created"
  type        = bool
  default     = true
}

variable "tasks_iam_policies" {
  description = "Map of the IAM Permissions the Fargate Tasks will need to access"
  type = map(object({
    Actions   = list(string),
    Effect    = string,
    Resources = list(string)
  }))
  default = {}
}

variable "tasks_iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = ""
}

variable "tasks_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = "/service-role/"
}

variable "tasks_iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`tasks_iam_role_name`) is used as a prefix"
  type        = bool
  default     = false
}

variable "ignore_task_definition_changes" {
  description = "Whether changes to service task_definition changes should be ignored"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy ordered_placement_strategy and placement_constraints updates"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(any)
  default = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters, they should be provided by the parent terragrunt config
# ---------------------------------------------------------------------------------------------------------------------
variable "env" {
  description = "Concord Environment"
  type        = string
}

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

variable "command" {
  type        = list(string)
  description = "The command that's passed to the container. This parameter maps to Cmd in the [Create a container](https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate) section of the [Docker Remote API](https://docs.docker.com/engine/api/v1.35/) and the COMMAND parameter to [docker run](https://docs.docker.com/engine/reference/run/#security-configuration)."
  default     = []
}

variable "entryPoint" {
  type        = list(string)
  description = "The entry point that's passed to the container. This parameter maps to Entrypoint in the [Create a container](https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate) section of the [Docker Remote API](https://docs.docker.com/engine/api/v1.35/) and the --entrypoint option to [docker run](https://docs.docker.com/engine/reference/run/#security-configuration)"
  default     = []
}

variable "acm_certificate_arn" {
  description = "Certificate ARN for a certificate that has been previously imported into ACM"
  type        = string
}
