terraform {
  backend "s3" {}
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# Публичные подсети
resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["eu-central-1a", "eu-central-1b", "eu-central-1c"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-${count.index}"
  }
}

# Приватные подсети
resource "aws_subnet" "private" {
  count = 3

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index + 3)
  availability_zone       = element(["eu-central-1a", "eu-central-1b", "eu-central-1c"], count.index)

  tags = {
    Name = "priv-subnet-${count.index}"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "eks-nat"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "priv-rt-${count.index}"
  }
}

# Route Table Associations
resource "aws_route_table_association" "pub_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "priv_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

