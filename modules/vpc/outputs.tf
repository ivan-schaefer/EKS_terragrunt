output "vpc_id" {
  description = "ID VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Список публичных сабнетов"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Список приватных сабнетов"
  value       = aws_subnet.private[*].id
}

