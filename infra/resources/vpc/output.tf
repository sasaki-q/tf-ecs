output "vpc_id" {
  description = "The vpc ID."
  value       = aws_vpc.main.id
}

output "default_sg_id" {
  value = aws_vpc.main.default_security_group_id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
