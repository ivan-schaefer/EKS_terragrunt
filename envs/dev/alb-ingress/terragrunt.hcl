include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/alb-ingress"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id        = "vpc-123456"
    public_subnets = ["subnet-aaa", "subnet-bbb"]
  }
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    eks_cluster_name = "mock-cluster"
    cluster_endpoint = "https://mock.eks.amazonaws.com"
  }
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnets    = dependency.vpc.outputs.public_subnets 
  cluster_name = dependency.eks.outputs.eks_cluster_name
  security_groups = [dependency.vpc.outputs.alb_security_group]
}

