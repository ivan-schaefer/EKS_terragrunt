include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/networking/network_acls"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    vpc_id               = "vpc-xxxxxx"
    public_subnets       = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    private_subnets      = ["subnet-xxxxxxxx", "subnet-yyyyyyyy", "subnet-zzzzzzzz"]
    vpc_cidr_block       = ["1.1.1.1/16"]
    azs                  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  }
}
inputs = {

  vpc_id                 = dependency.vpc.outputs.vpc_id
  public_subnets         = dependency.vpc.outputs.public_subnets
  private_subnets        = dependency.vpc.outputs.private_subnets
  vpc_cidr_block         = dependency.vpc.outputs.vpc_cidr_block
  eks-public-nacl_name   = "eks-public-nacl"
  eks-private-nacl_name  = "eks-private-nacl"
}
 
