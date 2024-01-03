data "aws_iam_policy_document" "main" {
  statement {
    effect = var.effect

    principals {
      type        = var.type
      identifiers = var.assume_role_identifiers
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.main.json
}
