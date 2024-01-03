variable "assume_role_identifiers" {
  type = list(string)
}

variable "effect" {
  type    = string
  default = "Allow"
}

variable "role_name" {
  type = string
}

variable "type" {
  type    = string
  default = "Service"
}
