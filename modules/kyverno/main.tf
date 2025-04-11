terraform {
  backend "s3" {}
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


data "aws_eks_cluster" "eks" {
  name = var.cluster_name

}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name

}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  }
}

resource "helm_release" "kyverno" {
  name       = "kyverno"
  namespace  = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = "v3.4.0"

  create_namespace = true

  values = [
    <<-EOF
    admissionController:
      replicas: 2
    EOF
  ]
}

resource "kubernetes_manifest" "kyverno_policies" {
  for_each = fileset("${path.module}/policies", "*.yaml")

  manifest = yamldecode(file("${path.module}/policies/${each.value}"))
}

