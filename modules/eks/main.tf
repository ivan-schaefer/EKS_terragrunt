# Terraform backend configuration and required providers
terraform {
  backend "s3" {}
  required_providers {
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

# Helm provider configuration using EKS token auth
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# Kubectl provider to apply custom Kubernetes manifests
provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# EKS

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  create_node_security_group = false
  create_cluster_security_group = false

  cluster_security_group_id = var.cluster_sg_id
  node_security_group_id    = var.node_sg_id

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id
 
  # Used by Karpenter to discover subnets and security groups
  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  # Optional managed node group used by Karpenter to bootstrap
  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["m5.large"]

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size 
      node_security_group_id = var.node_sg_id

      node_security_group_tags = {
        "karpenter.sh/discovery" = var.cluster_name
      }

      labels = {
        "karpenter.sh/controller" = "true"
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Required Service-Linked Role for EC2 Spot Instances (used by Karpenter)

resource "aws_iam_service_linked_role" "ec2_spot" {
  aws_service_name = "spot.amazonaws.com"
}

# Karpenter IAM and Pod Identity Setup

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true

  cluster_name = var.cluster_name

  # Optional policies for EC2 instance access (e.g., SSM)
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = var.environment
  }
  depends_on = [
    aws_iam_service_linked_role.ec2_spot,
    module.eks
]
}

# Karpenter Helm Installation (via OCI)

resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.0.0"
  wait       = false

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    controller:
      topologySpreadConstraints: []
    EOT
  ]

  depends_on = [module.eks]

}

# Karpenter NodePool Definition (custom provisioning config)

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = templatefile("${path.module}/karpenter_node_pool.yaml.tmpl", {
    instance_families    = var.karpenter_instance_families
    instance_sizes       = var.karpenter_instance_sizes
    instance_hypervisors = var.karpenter_instance_hypervisors
    capacity_types       = var.karpenter_capacity_types
    architectures        = var.karpenter_architectures
    cpu_limit            = var.karpenter_cpu_limit
  })

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

# Karpenter NodeClass Definition (sets subnet, AMI family, etc.)

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2023
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}
