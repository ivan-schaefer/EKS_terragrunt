output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

