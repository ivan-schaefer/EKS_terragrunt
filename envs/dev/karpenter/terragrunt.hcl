include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/karpenter"
}


dependencies {
  paths = ["../vpc", "../eks"]
}


inputs = {
  cluster_name           = "eks-cluster"
  environment            = "dev"
  karpenter_iam_role_name = "karpenter-node-role"
}