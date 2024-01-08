resource "aws_lb" "main" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_log_config.bucket_name
    prefix  = var.access_log_config.log_prefix
    enabled = var.access_log_config.enabled
  }
}
