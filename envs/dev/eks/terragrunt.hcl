include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "vpc-123456"
    public_subnets = ["subnet-123456", "subnet-654321"]
    private_subnets = ["subnet-abcdef", "subnet-fedcba"]
  }
}

inputs = {
  vpc_id         = dependency.vpc.outputs.vpc_id
  public_subnets = dependency.vpc.outputs.public_subnets
  private_subnets = dependency.vpc.outputs.private_subnets
}

