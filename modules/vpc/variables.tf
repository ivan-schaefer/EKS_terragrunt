variable "vpc_cidr" {
  description = "CIDR VPC"
  type        = string
}


variable "private_subnet_cidrs" {
  description = "CIDR приватных подсетей"
  type        = list(string)
}

variable "azs" {
  description = "Зоны доступности"
  type        = list(string)
}

