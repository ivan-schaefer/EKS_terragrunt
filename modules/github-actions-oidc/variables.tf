variable "aws_account_id" {
  description = "Your AWS account ID"
  type        = string
}

variable "github_repository" {
  description = "GitHub repo in format owner/repo (e.g., ivanschaefer/my-app)"
  type        = string
}

variable "region" { 
  description = "AWS region to deploy resources"
  type        = string
} 