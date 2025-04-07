terraform {
  backend "s3" {}
}


data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:ref:refs/heads/master"]
    }
  }
}
resource "aws_iam_role" "github_actions_oidc" {
  name               = "github-actions-oidc-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_readonly" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSReadOnlyAccess"
}