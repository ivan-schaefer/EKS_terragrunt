variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}


variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "karpenter_iam_role_name" {
  description = "The name of the IAM role for Karpenter"
  type        = string
}
