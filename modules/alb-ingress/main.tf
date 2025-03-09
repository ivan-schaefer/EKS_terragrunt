module "vpc" {
  source = "../vpc"

  cluster_name = var.cluster_name
}

terraform {
  backend "s3" {}
}

module "alb_ingress" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  name = "eks-alb-ingress"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false
}

