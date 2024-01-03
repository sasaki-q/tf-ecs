variable "name" {
  type = string
}

variable "iam_role_ids" {
  type = list(string)
}

variable "policy_arn" {
  type = string
}
