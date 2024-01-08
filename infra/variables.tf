################################################
# network
################################################

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "myvpc"
}

variable "public_subnets" {
  type = list(object({
    az   = string
    name = string
    cidr = string
  }))

  default = [
    {
      az   = "ap-northeast-1a"
      name = "ap-northeast-1a-public"
      cidr = "192.168.10.0/24"
    },
    {
      az   = "ap-northeast-1c"
      name = "ap-northeast-1c-public"
      cidr = "192.168.11.0/24"
    },
    {
      az   = "ap-northeast-1d"
      name = "ap-northeast-1d-public"
      cidr = "192.168.12.0/24"
    },
  ]
}

variable "private_subnets" {
  type = list(object({
    az   = string
    name = string
    cidr = string
  }))

  default = [
    {
      az   = "ap-northeast-1a"
      name = "ap-northeast-1a-private"
      cidr = "192.168.13.0/24"
    },
    {
      az   = "ap-northeast-1c"
      name = "ap-northeast-1c-private"
      cidr = "192.168.14.0/24"
    },
    {
      az   = "ap-northeast-1d"
      name = "ap-northeast-1d-private"
      cidr = "192.168.15.0/24"
    }
  ]
}

variable "database_subnets" {
  type = list(object({
    az   = string
    name = string
    cidr = string
  }))

  default = [
    {
      az   = "ap-northeast-1a"
      name = "ap-northeast-1a-private-database"
      cidr = "192.168.16.0/24"
    },
    {
      az   = "ap-northeast-1c"
      name = "ap-northeast-1c-private-database"
      cidr = "192.168.17.0/24"
    },
    {
      az   = "ap-northeast-1d"
      name = "ap-northeast-1d-private-database"
      cidr = "192.168.18.0/24"
    }
  ]
}

################################################
# security group
################################################
variable "database_sg_name" {
  type    = string
  default = "database-sg"
}

variable "private_sg_name" {
  type    = string
  default = "private-sg"
}

variable "vpc_endpoint_sg_name" {
  type    = string
  default = "vpc-endpoint-sg"
}

variable "security_group_names" {
  type = list(object({
    name = string
  }))

  default = [
    { name = "database-sg" },
    { name = "private-sg" },
    { name = "vpc-endpoint-sg" },
  ]
}

variable "endpoint_services" {
  type = list(object({
    type    = string
    service = string
  }))

  default = [
    {
      service = "com.amazonaws.ap-northeast-1.s3"
      type    = "Gateway"
    },
    {
      service = "com.amazonaws.ap-northeast-1.ecr.api"
      type    = "Interface"
    },
    {
      service = "com.amazonaws.ap-northeast-1.ecr.dkr"
      type    = "Interface"
    },
    {
      service = "com.amazonaws.ap-northeast-1.logs"
      type    = "Interface"
    }
  ]
}

################################################
# database
################################################

variable "db_subnet_group_name" {
  type    = string
  default = "db-subnet-group"
}

variable "db_name" {
  type    = string
  default = "project"
}

################################################
# route53
################################################

variable "domain_name" {
  type    = string
  default = ""
}

################################################
# load balancer
################################################

variable "alb_access_log_bucket_name" {
  type    = string
  default = "alb-access-log-bucket"
}

variable "alb_name" {
  type    = string
  default = "load-balancer"
}

variable "alb_type" {
  type    = string
  default = "application"
}

################################################
# container
################################################

variable "ecr" {
  type = list(object({
    name = string
  }))
  default = [
    { name = "application" }
  ]
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "ecs_components" {
  type = object({
    log_group_name = string
    cluster_name   = string
    family_name    = string
    container_name = string
    container_port = number
    service_name   = string
  })

  default = {
    log_group_name = "log_group"
    cluster_name   = "cluster"
    family_name    = "family"
    container_name = "container"
    container_port = 8080
    service_name   = "service"
  }
}
