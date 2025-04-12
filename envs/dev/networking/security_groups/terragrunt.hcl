include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/networking/security_groups"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    vpc_id               = "vpc-xxxxxx"
    public_subnet_ids    = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    private_subnet_ids   = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    vpc_cidr_block       = ["1.1.1.1/16"]
    azs                  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  }
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  alb_sg_name        = "eks-alb-sg"
  eks_nodes_sg_name  = "eks-nodes-sg"
  eks_cluster_sg_name = "eks-cluster-sg"
  vpc_id             = dependency.vpc.outputs.vpc_id
  cluster_name       = local.env.locals.cluster_name 
}
 
