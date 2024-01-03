variable "cidr" {
  type = string
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}


variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}
