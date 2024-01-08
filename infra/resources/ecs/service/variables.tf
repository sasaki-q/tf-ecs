################################################
# task
################################################

variable "task_family_name" {
  type = string
}

variable "network_mode" {
  type    = string
  default = "awsvpc"
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "requires_compatibilities" {
  type    = list(string)
  default = ["FARGATE"]
}

variable "execution_role_arn" {
  type = string
}

variable "container_config" {
  type = object({
    name           = string
    image          = string
    cpu            = number
    memory         = number
    container_port = number
    host_port      = number
    essential      = bool
  })
}

variable "log_driver" {
  type    = string
  default = "awslogs"
}

variable "log_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "log_prefix" {
  type    = string
  default = "ecs"
}

variable "log_group_name" {
  type = string
}

variable "env" {
  type = list(object({
    name  = string
    value = string
  }))
}

################################################
# service
################################################

variable "name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "launch_type" {
  type    = string
  default = "FARGATE"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "tg_group_id" {
  type = string
}
