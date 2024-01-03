resource "aws_vpc_security_group_ingress_rule" "main" {
  security_group_id = var.security_group_id

  cidr_ipv4                    = var.cidr
  ip_protocol                  = var.protocol
  from_port                    = var.from_port
  to_port                      = var.to_port
  referenced_security_group_id = var.source_security_group_id
}
