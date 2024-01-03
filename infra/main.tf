data "aws_caller_identity" "current" {}

locals {
  private_subnet_ids  = [for v in module.private_subnet : v.id]
  database_subnet_ids = [for v in module.database_subnet : v.id]
}

################################################
# network
################################################

module "vpc" {
  source = "./resources/vpc"

  cidr = var.vpc_cidr
  name = var.vpc_name
}

module "public_subnet" {
  source = "./resources/subnet"

  for_each = { for idx, val in var.public_subnets : idx => val }

  vpc_id         = module.vpc.vpc_id
  cidr           = each.value.cidr
  name           = each.value.name
  az             = each.value.az
  route_table_id = module.vpc.public_route_table_id
}

module "private_subnet" {
  source = "./resources/subnet"

  for_each = { for idx, val in var.private_subnets : idx => val }

  vpc_id         = module.vpc.vpc_id
  cidr           = each.value.cidr
  name           = each.value.name
  az             = each.value.az
  route_table_id = module.vpc.private_route_table_id
}

module "database_subnet" {
  source = "./resources/subnet"

  for_each = { for idx, val in var.database_subnets : idx => val }

  vpc_id         = module.vpc.vpc_id
  cidr           = each.value.cidr
  name           = each.value.name
  az             = each.value.az
  route_table_id = module.vpc.private_route_table_id
}

################################################
# security group
################################################

module "security_group" {
  source = "./resources/security_group"

  for_each = { for idx, val in var.security_group_names : idx => val }

  name   = each.value.name
  vpc_id = module.vpc.vpc_id
}

data "aws_security_group" "database" {
  name = var.database_sg_name

  depends_on = [module.security_group]
}

data "aws_security_group" "private" {
  name = var.private_sg_name

  depends_on = [module.security_group]
}

data "aws_security_group" "vpc_endpoint" {
  name = var.vpc_endpoint_sg_name

  depends_on = [module.security_group]
}

module "database_security_group_ingress" {
  source = "./resources/security_group/ingress"

  security_group_id        = data.aws_security_group.database
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = data.aws_security_group.private

  depends_on = [module.security_group]
}

module "vpc_endpoint_security_group_ingress" {
  source = "./resources/security_group/ingress"

  security_group_id        = data.aws_security_group.vpc_endpoint
  from_port                = 443
  to_port                  = 443
  source_security_group_id = data.aws_security_group.private

  depends_on = [module.security_group]
}

################################################
# vpc endpoint
################################################

module "endpoint" {
  source = "./resources/vpc/endpoint"

  for_each           = { for idx, val in var.endpoint_services : idx => val }
  vpc_id             = module.vpc.vpc_id
  service            = each.value.service
  type               = each.value.type
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [data.aws_security_group.vpc_endpoint]
  route_table_ids    = [module.vpc.private_route_table_id]

  depends_on = [module.security_group]
}

################################################
# database
################################################

resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = local.database_subnet_ids

  tags = {
    Name = var.db_subnet_group_name
  }
}

module "database" {
  source = "./resources/rds"

  name               = var.db_name
  subnet_group_name  = aws_db_subnet_group.main.name
  security_group_ids = [data.aws_security_group.database]

  depends_on = [module.security_group, aws_db_subnet_group.main]
}

################################################
# container
################################################

import {
  to = aws_ecr_repository.main
  id = "application"
}

resource "aws_ecr_repository" "main" {
  name                 = "application"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "kms" {
  source      = "./resources/kms"
  description = "for ecs cluster"
}

module "log_group" {
  source = "./resources/cloudwatch/log_group"

  name = var.ecs_components.log_group_name
}

module "cluster" {
  source = "./resources/ecs/cluster"

  name           = var.ecs_components.cluster_name
  kms_id         = module.kms.id
  log_group_name = module.log_group.name

  depends_on = [module.kms, module.log_group]
}

module "ecs_tasks_assume_role" {
  source = "./resources/iam/assume_role"

  assume_role_identifiers = ["ecs-tasks.amazonaws.com"]
  role_name               = "ecsTaskExecutionRole"
}

module "ecs_tasks_assume_role_attachment" {
  source = "./resources/iam/attachment"

  name         = "ecs_tasks_assume_role_attachment"
  iam_role_ids = [module.ecs_tasks_assume_role.id]
  policy_arn   = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  depends_on = [module.ecs_tasks_assume_role]
}

module "service" {
  source = "./resources/ecs/service"

  task_family_name   = var.ecs_components.family_name
  task_role_arn      = ""
  execution_role_arn = module.ecs_tasks_assume_role.arn
  container_config = {
    name           = var.ecs_components.container_name
    image          = "${resource.aws_ecr_repository.main.repository_url}:v0.1"
    cpu            = 256
    memory         = 512
    container_port = 8080
    host_port      = 8080
    essential      = true
  }

  log_group_name = module.log_group.name
  env = [
    {
      name  = "DB_HOST"
      value = module.database.address
    },
    {
      name  = "DB_PORT"
      value = "5432"
    },
    {
      name  = "DB_USER"
      value = module.database.username
    },
    {
      name  = "DB_PASSWORD"
      value = module.database.password
    },
    {
      name  = "DB_NAME"
      value = module.database.name
    }
  ]

  name               = var.ecs_components.service_name
  cluster_id         = module.cluster.id
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [data.aws_security_group.private]

  depends_on = [
    module.endpoint,
    module.cluster,
    module.ecs_tasks_assume_role_attachment
  ]
}
