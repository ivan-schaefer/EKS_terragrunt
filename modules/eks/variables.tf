variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "karpenter_instance_families" {
  type        = list(string)
  description = "Allowed EC2 instance families for Karpenter"
}

variable "karpenter_instance_sizes" {
  type        = list(string)
  description = "Allowed EC2 instance sizes for Karpenter"
}

variable "karpenter_instance_hypervisors" {
  type        = list(string)
  description = "Allowed EC2 instance hypervisors for Karpenter"
}

variable "karpenter_capacity_types" {
  type        = list(string)
  description = "Allowed capacity types (e.g., spot, on-demand) for Karpenter"
}

variable "karpenter_architectures" {
  type        = list(string)
  description = "Supported CPU architectures for Karpenter nodes"
}

variable "karpenter_cpu_limit" {
  type        = number
  description = "CPU limit for the Karpenter provisioner"
}

variable "eks_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "nodes_sg_id" {
  description = "Security group for EKS worker nodes and Karpenter"
  type        = string
}

variable "cluster_sg_id" {
  description = "Security group for EKS cluster"
  type        = string
  
}

variable "ami_type" {
  description = "AMI type for the EKS worker nodes"
  type        = string
  
}

variable "instance_type" { 
  description = "Instance type for the EKS worker nodes"
  type        = string
  
}