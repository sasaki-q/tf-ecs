resource "aws_vpc_endpoint" "main" {
  vpc_id              = var.vpc_id
  service_name        = var.service
  vpc_endpoint_type   = var.type
  private_dns_enabled = var.type == "Interface" ? var.private_dns_enabled : null
  subnet_ids          = var.type == "Interface" ? var.subnet_ids : null
  security_group_ids  = var.type == "Interface" ? var.security_group_ids : null
  route_table_ids     = var.type == "Interface" ? null : var.route_table_ids
}
