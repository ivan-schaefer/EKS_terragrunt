variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string

}

variable "public_subnets" {
  description = "List of private subnet IDs."
  type        = list(string)

}

variable "private_subnets" {
  description = "List of public subnet IDs."
  type        = list(string)

}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  type        = string

}

variable "eks-public-nacl_name" {
  description = "Name of the public NACL."
  type        = string
  
}

variable "eks-private-nacl_name" {
  description = "Name of the private NACL."
  type        = string
  
}