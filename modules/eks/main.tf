terraform {
  backend "s3" {}
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  ivpc_id         = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa     = true

  tags = {
    Environment = "dev"
  }

}
