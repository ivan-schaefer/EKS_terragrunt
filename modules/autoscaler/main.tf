terraform {
  backend "s3" {}
}


resource "aws_iam_policy" "eks_autoscaler" {
  name        = "eks-cluster-autoscaler"
  path        = "/"
  description = "EKS Cluster Autoscaler policy"

  policy = file("${path.module}/autoscaler-policy.json")
}
