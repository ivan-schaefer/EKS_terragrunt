# S3 backend config (managed by Terragrunt, usually overridden)

terraform {
  backend "s3" {}
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  }
}

# Load shared environment configuration from parent directory (e.g., cluster name, environment)
locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

# Fetch EKS cluster metadata
data "aws_eks_cluster" "eks" {
  name = local.env.locals.cluster_name
}

# Fetch EKS token for authentication
data "aws_eks_cluster_auth" "eks" {
  name = local.env.locals.cluster_name
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.36.0"

  create_namespace = true

  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP
      extraArgs:
        - --insecure
    EOT
  ]
}

