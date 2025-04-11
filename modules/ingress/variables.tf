variable "alb_role_name" {
  type        = string
  description = "IAM role name for the ALB ingress controller"
}

variable "alb_extra_permission_name" {
  type        = string
  description = "Name for extra policy attached to ALB role"
}

variable "alb_sa_name" {
  type        = string
  description = "Kubernetes service account name for ALB controller"
}

variable "alb_ns" {
  type        = string
  description = "Namespace where the ALB controller service account will be created"
}
