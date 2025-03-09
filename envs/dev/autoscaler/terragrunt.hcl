include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/autoscaler"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    eks_cluster_id    = "mock-cluster"
    eks_iam_role_arn  = "arn:aws:iam::123456789012:role/mock-eks-role"
  }
}

inputs = {
  cluster_name = dependency.eks.outputs.eks_cluster_name
  iam_role_arn = dependency.eks.outputs.eks_iam_role_arn
}


