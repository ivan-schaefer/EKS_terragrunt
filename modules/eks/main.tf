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


###############################################################################
# EKS
###############################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }


  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 4
      desired_size = 1


      node_security_group_tags = {
        "karpenter.sh/discovery" = var.cluster_name
      }

      labels = {
        "karpenter.sh/controller" = "true"
      }
  }

  tags = {
    Environment = var.environment
  }
}
}
###############################################################################
# EC2 Spot Service-Linked Role (required for Karpenter Spot support)
###############################################################################
resource "aws_iam_service_linked_role" "ec2_spot" {
  aws_service_name = "spot.amazonaws.com"
}

###############################################################################
# Karpenter
###############################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true
  cluster_name = var.cluster_name
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = var.environment
  }
  depends_on = [
    aws_iam_service_linked_role.ec2_spot
  ]
}

resource "null_resource" "wait_for_eks_ready" {
  provisioner "local-exec" {
    command = "echo 'Waiting for EKS to be ready...' && sleep 180"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [module.eks]
}

resource "null_resource" "wait_for_eks_ready" {
  provisioner "local-exec" {
    command = "echo 'Waiting for EKS to be ready...' && sleep 180"
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [module.eks]
}

###############################################################################
# Karpenter Helm
###############################################################################
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

  depends_on = [
    null_resource.wait_for_eks_ready
  ]

}
###############################################################################
# Karpenter Kubectl
###############################################################################

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-family"
              operator: In
              values: ["t3", "t4g", "m6g", "c6g"]
            - key: "karpenter.k8s.aws/instance-size"
              operator: In
              values: ["small", "medium", "large"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ["spot"]
            - key: "kubernetes.io/arch"
              operator: In
              values: ["amd64", "arm64"]
      limits:
        cpu: 500
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

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
