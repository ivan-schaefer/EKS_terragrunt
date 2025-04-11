include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id               = "vpc-xxxxxx"
    private_subnets      = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    azs                  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  }
}

dependencies {
  paths = ["../networking/security_groups", "../networking/network_acls"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  eks_version                    = 1.32
  vpc_id                         = dependency.vpc.outputs.vpc_id
  private_subnets                = dependency.vpc.outputs.private_subnets
  azs                            = dependency.vpc.outputs.azs
  min_size                       = 1
  max_size                       = 4
  desired_size                   = 2
  karpenter_instance_families    = ["t3", "t4g", "m6g", "c6g"]
  karpenter_instance_sizes       = ["small", "medium", "large"]
  karpenter_instance_hypervisors = ["nitro"]
  karpenter_capacity_types       = ["spot"]
  karpenter_architectures        = ["amd64", "arm64"]
  karpenter_cpu_limit            = 50
  environment                    = local.env.locals.environment
  cluster_name                   = local.env.locals.cluster_name
}





