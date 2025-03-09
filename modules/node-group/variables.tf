variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "nodes_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the node group"
  type        = string
}

variable "subnets" {
  description = "List of private subnets for the node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "cluster_service_cidr" {
  description = "CIDR block for Kubernetes service network"
  type        = string
}
