output "nodes_sg_id" {
  description = "Security Group ID for EKS nodes"
  value       = aws_security_group.nodes_sg.id
}

output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

