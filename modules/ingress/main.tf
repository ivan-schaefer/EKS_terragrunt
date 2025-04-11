terraform {
  backend "s3" {}


  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
    alb_controller_policies = {
    alb_controller_permissions        = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess" ### ALB Ingress Controller permissions
    alb_ingress_controller_policy     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" ### EKS Cluster policy
    alb_vpc_resource_controller_policy = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"   ### EKS VPC Resource Controller policy
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
### read data from current AWS user (accountid, user_id, arn)
data "aws_caller_identity" "current" {}

### read data from current AWS EKS cluster
data "aws_eks_cluster" "eks" {
  name = local.env.locals.cluster_name
}
### read data from current AWS EKS cluster OIDC provider
data "aws_eks_cluster_auth" "eks" {
  name = local.env.locals.cluster_name
}

### Create IAM role for ALB Ingress Controller 
resource "aws_iam_role" "alb_ingress_controller" {
  name = var.alb_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}" ### OIDC provider for EKS IRSA access
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller" ### only SA from kube-system namespace can assume this role
          }
        }
      }
    ]
  })
}


### This is required for ALB Ingress Controller to work with WAFv2 and Shield

resource "aws_iam_role_policy" "alb_controller_extra_permissions" {
  name = var.alb_extra_permission_name
  role = aws_iam_role.alb_ingress_controller.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "waf-regional:GetWebACLForResource",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection",
          "ec2:AuthorizeSecurityGroupIngress"
        ],
        Resource = "*"
      }
    ]
  })
}
### Attach IAM policies to the role

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachments" {
  for_each   = local.alb_controller_policies
  role       = aws_iam_role.alb_ingress_controller.name
  policy_arn = each.value
}


### Create EKS SA with IAM anootation for ALB Ingress Controller

resource "kubernetes_service_account" "alb_ingress_controller" {
  metadata {
    name      = var.alb_sa_name
    namespace = var.alb_ns
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller.arn
    }
  }
}

### Install HELM chart for ALB Ingress Controller

resource "helm_release" "alb_ingress_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.3"

  values = [
    <<-EOT
    clusterName: "${local.env.locals.cluster_name}"
    serviceAccount:
      create: false
      name: aws-load-balancer-controller
    EOT
  ]

  depends_on = [
    kubernetes_service_account.alb_ingress_controller,
    aws_iam_role_policy_attachment.alb_ingress_controller_policy,
    aws_iam_role_policy_attachment.alb_vpc_resource_controller_policy
  ]
}


