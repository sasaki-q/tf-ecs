variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "protocol" {
  type    = string
  default = "tcp"
}
