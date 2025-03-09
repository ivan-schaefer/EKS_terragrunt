terraform {
  backend "s3" {}
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id         = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa     = true

  tags = {
    Environment = "dev"
  }


}

module "vpc" {
  source = "../vpc"

  vpc_id         = dependency.vpc.outputs.vpc_id
  public_subnets = dependency.vpc.outputs.public_subnets
  private_subnets = dependency.vpc.outputs.private_subnets
}
