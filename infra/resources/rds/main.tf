resource "aws_db_instance" "main" {
  allocated_storage           = 10
  identifier                  = var.name
  engine                      = var.engine.engine
  engine_version              = var.engine.version
  instance_class              = var.instance_class
  db_name                     = var.name
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password
  skip_final_snapshot         = var.skip_final_snapshot
  vpc_security_group_ids      = var.security_group_ids
  db_subnet_group_name        = var.subnet_group_name
}
