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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "grafana_remote_write" {
  depends_on = [kubernetes_namespace.monitoring]
  metadata {
    name      = "kubepromsecret"
    namespace = var.namespace
  }
  
  data = {
    username = var.grafana_cloud_username
    password = var.grafana_cloud_api_key
  }

  type = "Opaque"
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = true
  version          = "55.5.0"

  depends_on = [kubernetes_secret.grafana_remote_write]

  values = [
    <<-EOF
      grafana:
        enabled: false

      alertmanager:
        enabled: false

      prometheus:
        prometheusSpec:
          remoteWrite:
            - url: "${var.grafana_cloud_prometheus_url}"
              basicAuth:
                username:
                  name: kubepromsecret
                  key: username
                password:
                  name: kubepromsecret
                  key: password
          serviceMonitorSelectorNilUsesHelmValues: false
          podMonitorSelectorNilUsesHelmValues: false
    EOF
  ]
}