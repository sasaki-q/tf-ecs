variable "security_group_id" {
  type = string
}

variable "cidr" {
  type    = string
  default = null
}

variable "from_port" {
  type    = string
  default = null
}

variable "to_port" {
  type    = string
  default = null
}

variable "protocol" {
  type    = string
  default = "tcp"
}

variable "source_security_group_id" {
  type    = string
  default = null
}
