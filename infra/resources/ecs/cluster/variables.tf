variable "name" {
  type = string
}

variable "kms_id" {
  type = string
}

variable "logging_type" {
  type    = string
  default = "OVERRIDE"
}

variable "cloud_watch_encryption_enabled" {
  type    = bool
  default = true
}

variable "log_group_name" {
  type = string
}
