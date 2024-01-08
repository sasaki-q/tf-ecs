variable "name" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type    = bool
  default = false
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "access_log_config" {
  type = object({
    enabled     = bool
    bucket_name = string
    log_prefix  = string
  })
}
