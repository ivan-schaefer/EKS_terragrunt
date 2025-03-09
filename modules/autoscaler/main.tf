terraform {
  backend "s3" {}
}


resource "aws_iam_policy" "eks_autoscaler" {
  name        = "eks-cluster-autoscaler"
  path        = "/"
  description = "EKS Cluster Autoscaler policy"
  policy = file("${path.module}/autoscaler-policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_autoscaler_attach" {
  policy_arn = aws_iam_policy.eks_autoscaler.arn
  role       = var.iam_role_arn
}
