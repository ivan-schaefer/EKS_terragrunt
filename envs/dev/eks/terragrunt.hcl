include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id          = "vpc-xxxxxx"
    private_subnets = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    public_subnets  = ["subnet-aaaaaaa", "subnet-bbbbbbb", "subnet-ccccccc"]
    azs            = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
}

inputs = {
  cluster_name  = "eks-cluster"
  cluster_version = 1.32
  vpc_id        = dependency.vpc.outputs.vpc_id
  subnet_ids    = dependency.vpc.outputs.private_subnets
  public_subnet_ids = dependency.vpc.outputs.public_subnets
  private_subnet_cidrs = dependency.vpc.outputs.private_subnet_cidrs
}

