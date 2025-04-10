# EKS Infrastructure with Terragrunt

This repository contains infrastructure code for deploying and managing an AWS Elastic Kubernetes Service (EKS) cluster using [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/). The structure is modular, DRY-compliant, and supports multiple environments and AWS accounts.

## 📁 Project Structure


```text
.
├── envs/                            # Environment configurations
│   ├── dev/                         # Development environment
│   │   ├── eks/                     # EKS configuration for dev
│   │   ├── monitoring/              # Monitoring stack (Prometheus, Loki, etc.)
│   │   ├── alb-controller/          # AWS Load Balancer Controller
│   │   ├── karpenter/               # Karpenter autoscaler
│   │   ├── argocd/                  # ArgoCD installation
│   │   ├── vpc/                     # VPC definition
│   │   ├── iam/                     # IAM roles/policies
│   │   └── cicd/   # OIDC provider for GitHub Actions
│
├── modules/                         # Reusable Terraform modules
│   ├── eks/                         # EKS module
│   ├── karpenter/                   # Karpenter module
│   ├── vpc/                         # VPC module
│   ├── alb-controller/              # ALB Controller module
│   ├── monitoring/                  # Monitoring stack (Prometheus, etc.)
│   ├── argocd/                      # ArgoCD module
│   ├── iam/                         # IAM roles and policies
│   └── cicd/                        # OIDC GitHub provider module
│
├── terragrunt.hcl                   # Root Terragrunt configuration


## 🚀 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) installed
- AWS CLI configured with appropriate credentials (`aws configure`)
- IAM role with sufficient permissions to create EKS and related resources

### Deployment Example

Navigate to the desired environment directory and run:

```bash
cd envs/dev/eu-central-1/eks
terragrunt init
terragrunt apply