terraform {
  backend "s3" {}
}


resource "aws_security_group" "cluster_sg" {
  name        = var.eks_cluster_sg_name
  description = "EKS Cluster SG for control plane"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow communication from cluster SG to itself"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.eks_cluster_sg_name
  }
}


resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.alb_sg_name

  }
}




### 🚀 Node Security Group (для Karpenter или managed node group)
resource "aws_security_group" "nodes_sg" {
  name        = var.eks_nodes_sg_name
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id

  # Node-to-node (self)
  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Cluster API → Node (kubelet on 443)
  ingress {
    description     = "Cluster API to node"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster_sg.id]
  }

  # ALB → NodePort
  ingress {
    description     = "Allow pods to receive traffic from ALB"
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # DNS
  ingress {
    description = "Allow DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                   = var.eks_nodes_sg_name
    "karpenter.sh/discovery" = var.cluster_name
  }
}
