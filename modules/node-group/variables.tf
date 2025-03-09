variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "instance_type" {
  description = "Instance type for worker nodes"
  type        = string
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

variable "nodes_name" {
  description = "Name for nodes"
  type        = string
}

