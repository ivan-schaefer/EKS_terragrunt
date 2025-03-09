include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/alb-ingress"
}

dependencies {
  paths = ["../vpc", "../eks"]
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets
  cluster_name = dependency.eks.outputs.cluster_name
}

