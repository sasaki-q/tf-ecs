locals {
  public_subnet_ids   = [for v in module.public_subnet : v.id]
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

  security_group_id        = data.aws_security_group.database.id
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = data.aws_security_group.private.id

  depends_on = [module.security_group]
}

module "vpc_endpoint_security_group_ingress" {
  source = "./resources/security_group/ingress"

  security_group_id        = data.aws_security_group.vpc_endpoint.id
  from_port                = 443
  to_port                  = 443
  source_security_group_id = data.aws_security_group.private.id

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
  security_group_ids = [data.aws_security_group.vpc_endpoint.id]
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
  security_group_ids = [data.aws_security_group.database.id]

  depends_on = [module.security_group, aws_db_subnet_group.main]
}

################################################
# route53
################################################

resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_zone" "stg" {
  name = "stg.${aws_route53_zone.main.name}"

  tags = {
    Environment = "staging"
  }
}

resource "aws_route53_record" "stg_ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_route53_zone.stg.name
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.stg.name_servers
}

resource "aws_acm_certificate" "main" {
  domain_name               = aws_route53_zone.stg.name
  validation_method         = "DNS"
  subject_alternative_names = ["*.${aws_route53_zone.stg.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

################################################
# application load balancer
################################################

resource "aws_s3_bucket" "alb_access_log_bucket" {
  bucket = var.alb_access_log_bucket_name
}

data "aws_iam_policy_document" "allow_access_from_alb" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::582318560864:root"]
    }

    actions = ["s3:PutObject"]
    effect  = "Allow"

    resources = [
      aws_s3_bucket.alb_access_log_bucket.arn,
      "${aws_s3_bucket.alb_access_log_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_alb" {
  bucket = aws_s3_bucket.alb_access_log_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_alb.json

  depends_on = [aws_s3_bucket.alb_access_log_bucket]
}

resource "aws_security_group" "alb_security_group" {
  name   = "alb-security-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

module "alb" {
  source = "./resources/lb"

  name               = var.alb_name
  load_balancer_type = var.alb_type
  subnet_ids         = local.public_subnet_ids
  security_group_ids = [aws_security_group.alb_security_group.id]

  access_log_config = {
    bucket_name = split(".", aws_s3_bucket.alb_access_log_bucket.bucket_domain_name)[0]
    log_prefix  = "alb-access-log"
    enabled     = true
  }

  depends_on = [aws_s3_bucket_policy.allow_access_from_alb, aws_security_group.alb_security_group]
}

resource "aws_lb_target_group" "main" {
  name        = "alb-target-group-${substr(uuid(), 0, 6)}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    interval = 300
    path     = "/hc"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = module.alb.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.main.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.stg.zone_id
  name    = "api.${aws_route53_zone.stg.name}"
  type    = "A"

  alias {
    zone_id                = module.alb.zone_id
    name                   = module.alb.dns_name
    evaluate_target_health = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

################################################
# container
################################################

import {
  to = aws_ecr_repository.main
  id = var.ecr[0].name
}

resource "aws_ecr_repository" "main" {
  name                 = var.ecr[0].name
  image_tag_mutability = var.image_tag_mutability

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
  execution_role_arn = module.ecs_tasks_assume_role.arn
  container_config = {
    name           = var.ecs_components.container_name
    image          = "${resource.aws_ecr_repository.main.repository_url}:v0.1"
    cpu            = 256
    memory         = 512
    container_port = var.ecs_components.container_port
    host_port      = var.ecs_components.container_port
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
      value = tostring(module.database.port)
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
  security_group_ids = [data.aws_security_group.private.id]
  tg_group_id        = aws_lb_target_group.main.id

  depends_on = [
    module.endpoint,
    module.cluster,
    module.ecs_tasks_assume_role_attachment
  ]
}

module "private_subnet_security_group_ingress" {
  source = "./resources/security_group/ingress"

  security_group_id        = data.aws_security_group.private.id
  from_port                = var.ecs_components.container_port
  to_port                  = var.ecs_components.container_port
  source_security_group_id = aws_security_group.alb_security_group.id
}
