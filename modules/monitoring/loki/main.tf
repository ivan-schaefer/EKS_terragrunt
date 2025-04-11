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

data "aws_eks_cluster" "eks" {
  name = var.cluster_name

}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name

}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "grafana_cloud_logs" {
  depends_on = [kubernetes_namespace.monitoring]

  metadata {
    name      = var.secret_name
    namespace = var.namespace
  }

  data = {
    username = var.grafana_cloud_user
    password = var.grafana_cloud_api_key
  }

  type = "Opaque"
}

resource "helm_release" "promtail" {
  name             = "promtail"
  namespace        = var.namespace
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  version          = "6.15.3"
  create_namespace = true

  depends_on = [kubernetes_secret.grafana_cloud_logs]

  values = [
    <<-EOF
    config:
      server:
        log_level: info
        http_listen_port: 3101

      positions:
        filename: /tmp/positions.yaml

      clients:
        - url: ${var.grafana_cloud_loki_url}/loki/api/v1/push
          basic_auth:
            username:
              name: ${var.secret_name}
              key: username
            password:
              name: ${var.secret_name}
              key: password

      scrape_configs:
        - job_name: kubernetes-pods
          pipeline_stages:
            - docker: {}
          static_configs:
            - targets: ["localhost"]
              labels:
                job: kubernetes-pods
                __path__: /var/log/pods/*/*/*.log

          relabel_configs:
            - source_labels: [__meta_kubernetes_pod_node_name]
              target_label: __host__
            - source_labels: [__path__]
              target_label: filename
            - source_labels: [__meta_kubernetes_namespace]
              target_label: namespace
            - source_labels: [__meta_kubernetes_pod_name]
              target_label: pod
            - source_labels: [__meta_kubernetes_pod_container_name]
              target_label: container

    EOF
  ]
}

