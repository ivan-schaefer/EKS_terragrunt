variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
