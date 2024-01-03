output "id" {
  value = aws_db_instance.main.id
}

output "arn" {
  value = aws_db_instance.main.arn
}

output "address" {
  value = aws_db_instance.main.address
}

output "endpoint" {
  // address:port
  value = aws_db_instance.main.endpoint
}

output "name" {
  value = aws_db_instance.main.db_name
}

output "username" {
  value = aws_db_instance.main.username
}

output "password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
