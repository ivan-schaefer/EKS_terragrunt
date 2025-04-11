variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "alb_sg_name" {
  description = "The name of the ALB security group."
  type        = string
}

variable "eks_nodes_sg_name" {
  description = "The name of the EKS nodes security group."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}