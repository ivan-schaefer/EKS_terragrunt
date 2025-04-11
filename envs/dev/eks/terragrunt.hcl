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
    subnet_ids           = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    azs                  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  }
}

inputs = {
  eks_version                    = 1.32
  vpc_id                         = dependency.vpc.outputs.vpc_id
  subnet_ids                     = dependency.vpc.outputs.subnet_ids
  azs                            = dependency.vpc.outputs.azs
  min_size                       = 1
  max_size                       = 3
  desired_size                   = 2
  karpenter_instance_families    = ["t3", "t4g", "m6g", "c6g"]
  karpenter_instance_sizes       = ["small", "medium", "large"]
  karpenter_instance_hypervisors = ["nitro"]
  karpenter_capacity_types       = ["spot"]
  karpenter_architectures        = ["amd64", "arm64"]
  karpenter_cpu_limit            = 50
}



