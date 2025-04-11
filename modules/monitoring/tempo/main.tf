terraform {
  backend "s3" {}

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

resource "kubernetes_secret" "grafana_tempo" {
  depends_on = [kubernetes_namespace.monitoring]
  metadata {
    name      = var.tempo_secret_name
    namespace = var.namespace
  }

  data = {
    username = var.tempo_username
    password = var.tempo_password
  }

  type = "Opaque"
}

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  namespace  = var.namespace
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.74.0"

  depends_on = [kubernetes_secret.grafana_tempo]

  values = [
    <<-EOF
    mode: deployment
    config:
      exporters:
        otlphttp:
          endpoint: "${var.tempo_url}"
          headers:
            Authorization: Basic ${base64encode("${var.tempo_username}:${var.tempo_password}")}
      service:
        pipelines:
          traces:
            receivers: [otlp]
            exporters: [otlphttp]
    EOF
  ]
}