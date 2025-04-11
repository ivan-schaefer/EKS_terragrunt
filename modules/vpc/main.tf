# S3 backend config (managed by Terragrunt, usually overridden)
terraform {
  backend "s3" {}
}

# Load shared environment configuration from parent directory (e.g., cluster name, environment)

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

  manage_default_network_acl    = false
  manage_default_security_group = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = {
    Environment = var.environment
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

}