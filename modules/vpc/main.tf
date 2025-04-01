terraform {
  backend "s3" {}
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "eks-vpc"
  cidr = var.cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = var.environment
    "karpenter.sh/discovery" = "eks-cluster"
  }
  private_subnet_tags = {
  "karpenter.sh/discovery" = "eks-cluster"
  }
}