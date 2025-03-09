terraform {
  backend "s3" {}
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  enable_irsa     = true

  tags = {
    Environment = "dev"
  }


}

