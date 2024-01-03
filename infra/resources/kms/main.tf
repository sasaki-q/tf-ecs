resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = 10
}
