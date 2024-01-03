resource "aws_ecs_cluster" "main" {
  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_id
      logging    = var.logging_type

      log_configuration {
        cloud_watch_encryption_enabled = var.cloud_watch_encryption_enabled
        cloud_watch_log_group_name     = var.log_group_name
      }
    }
  }
}
