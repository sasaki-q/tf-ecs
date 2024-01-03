variable "name" {
  type = string
}

variable "engine" {
  type = object({
    engine  = string
    version = string
  })
  default = {
    engine  = "postgres"
    version = "14.5"
  }
}

variable "subnet_group_name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "username" {
  type    = string
  default = "postgres"
}

variable "manage_master_user_password" {
  type    = bool
  default = true
}
