output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}


output "private_subnets" {
  value = aws_subnet.private[*].id 
}

output "public_subnets" {
  value = aws_subnet.public[*].id 
}
output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

