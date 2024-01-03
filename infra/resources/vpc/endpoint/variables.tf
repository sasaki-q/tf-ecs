variable "vpc_id" {
  type = string
}

variable "service" {
  type = string
}

variable "type" {
  type = string
}

variable "private_dns_enabled" {
  type    = bool
  default = true
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

variable "route_table_ids" {
  type    = list(string)
  default = null
}
