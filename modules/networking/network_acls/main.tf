terraform {
  backend "s3" {}
}

# Public NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnets

  tags = {
    "Name" = var.eks-public-nacl_name
  }
}

resource "aws_network_acl_rule" "public_ingress_http" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_ingress_https" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "6" # TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_egress_all" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 120
  egress         = true
  protocol       = "-1" #ALL
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Private NACL
resource "aws_network_acl" "private_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  tags = {
    "Name" = var.eks-private-nacl_name
  }
}

resource "aws_network_acl_rule" "private_ingress_internal" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1" #ALL
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_block
}

resource "aws_network_acl_rule" "private_egress_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = true
  protocol       = "-1" #ALL
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
