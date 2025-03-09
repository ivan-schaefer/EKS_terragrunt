include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/node-group"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name    = "mock-cluster"
    cluster_endpoint = "https://mock.eks.amazonaws.com"
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id               = "vpc-xxxxxxx"
    private_subnets      = ["subnet-aaaa", "subnet-bbbb"]
    vpc_cidr             = "10.0.0.0/16"
  }
}

inputs = {
  cluster_name  = dependency.eks.outputs.eks_cluster_name
  vpc_id        = dependency.vpc.outputs.vpc_id
  subnets       = dependency.vpc.outputs.private_subnets
  nodes_name    = "eks-node-group"
  instance_type = "t3.medium"
  desired_size  = 2
  min_size      = 1
  max_size      = 5
  cluster_service_cidr      = dependency.vpc.outputs.vpc_cidr

  node_group_role_arn = dependency.eks.outputs.eks_iam_role_arn
}

