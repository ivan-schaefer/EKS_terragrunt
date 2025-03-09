terraform {
  backend "s3" {}
}

module "alb_ingress" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  name   = "eks-alb-ingress"
  vpc_id = var.vpc_id
  subnets = var.subnets  

  enable_deletion_protection = false
}

