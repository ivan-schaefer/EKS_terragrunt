terraform {
  backend "s3" {}
}
module "node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  name = var.nodes_name
  instance_types  = [var.instance_type]
  subnet_ids      = var.subnets
  cluster_service_cidr = var.cluster_service_cidr
  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
  tags = {
    Name        = "eks-nodes"
    Environment = "dev"
  }
}

