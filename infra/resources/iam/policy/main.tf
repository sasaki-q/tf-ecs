data "aws_iam_policy_document" "main" {
  statement {
    effect    = var.effect
    actions   = var.actions
    resources = var.resources
  }
}

resource "aws_iam_policy" "main" {
  name   = var.name
  policy = data.aws_iam_policy_document.main.json
}
