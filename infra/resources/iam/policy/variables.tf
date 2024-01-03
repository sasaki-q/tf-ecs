variable "effect" {
  type    = string
  default = "Allow"
}

variable "resources" {
  type    = list(string)
  default = ["*"]
}

variable "actions" {
  type = list(string)
}

variable "name" {
  type = string
}
