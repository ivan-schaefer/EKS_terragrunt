# S3 backend config (managed by Terragrunt, usually overridden)
terraform {
  backend "s3" {}
}

# Load shared environment configuration from parent directory (e.g., cluster name, environment)
locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = var.vpc_name
  cidr = var.cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = {
    Environment = local.env.locals.environment
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = local.env.locals.cluster_name
  }

}