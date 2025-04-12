include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"

    before_hook "scale_down_node_group" {
    commands = ["destroy"]
    execute  = [
      "terragrunt",
      "apply",
      "-auto-approve",
      "-target=module.eks.module.eks_managed_node_group[\"karpenter\"]",
      "-var=desired_size=0"
    ]
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id               = "vpc-xxxxxx"
    private_subnets      = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    azs                  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  }
}

dependency "nacl"{
  config_path = "../networking/network_acls"
  
  mock_outputs = {
    nacl_output = "mock-value"
  }
}

dependency "security_groups" {
  config_path = "../networking/security_groups"

  mock_outputs = {
    nodes_sg_id   = "sg-12345678"
  }
}


locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  eks_version                    = 1.32
  vpc_id                         = dependency.vpc.outputs.vpc_id
  private_subnets                = dependency.vpc.outputs.private_subnets
  azs                            = dependency.vpc.outputs.azs
  node_sg_id                     = dependency.security_groups.outputs.nodes_sg_id
  min_size                       = 1
  max_size                       = 4
  desired_size                   = 1
  karpenter_instance_families    = ["t3", "t4g", "m6g", "c6g"]
  karpenter_instance_sizes       = ["small", "medium", "large"]
  karpenter_instance_hypervisors = ["nitro"]
  karpenter_capacity_types       = ["spot"]
  karpenter_architectures        = ["amd64", "arm64"]
  karpenter_cpu_limit            = 50
  environment                    = local.env.locals.environment
  cluster_name                   = local.env.locals.cluster_name
}





