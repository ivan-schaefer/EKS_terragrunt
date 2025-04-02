output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "azs" {
  description = "List of availability zones"
  value       = module.vpc.azs
}

output "subnet_ids" {
  value       = module.vpc.private_subnets
}