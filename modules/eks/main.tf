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
  enable_cluster_creator_admin_permissions = true

  enable_irsa     = true


  eks_managed_node_groups = {
  example = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = ["t3.medium"]
    min_size     = 1
    max_size     = 3
    desired_size = 2
    }
  }


  tags = {
    Environment = "dev"
  }


}

