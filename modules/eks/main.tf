terraform {
  backend "s3" {}
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true
  
  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }
  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  tags = {
    Environment = var.environment
  }
}

