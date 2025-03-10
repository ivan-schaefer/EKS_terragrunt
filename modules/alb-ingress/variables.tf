variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "security_groups" {
  description = "List of security groups to assign to the ALB"
  type        = list(string)
}


