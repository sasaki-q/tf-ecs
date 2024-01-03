resource "aws_iam_policy_attachment" "main" {
  name       = var.name
  roles      = var.iam_role_ids
  policy_arn = var.policy_arn
}
