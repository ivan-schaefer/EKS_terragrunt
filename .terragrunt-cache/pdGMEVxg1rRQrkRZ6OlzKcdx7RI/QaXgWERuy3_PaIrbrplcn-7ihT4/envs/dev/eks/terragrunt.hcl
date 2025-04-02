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
  cluster_name         = "eks-cluster"
  cluster_version      = 1.32
  vpc_id               = dependency.vpc.outputs.vpc_id
  subnet_ids           = dependency.vpc.outputs.subnet_ids
  azs                  = dependency.vpc.outputs.azs
  environment          = "dev"
}



