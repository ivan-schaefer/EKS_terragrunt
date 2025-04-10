# EKS Infrastructure with Terragrunt

This repository contains infrastructure code for deploying and managing an AWS Elastic Kubernetes Service (EKS) cluster using [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/). The structure is modular, DRY-compliant, and supports multiple environments and AWS accounts.

## 📁 Project Structure


<pre>
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
</pre>

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

---

## 🛠 Features

- 🔁 **Modular Design** – Reusable Terraform modules for EKS, VPC, IAM, etc.
- 🌍 **Multi-environment & Multi-account** – Structured per environment (dev/prod) and AWS account
- ☸️ **EKS Cluster Bootstrapping** – Includes setup for core components via Helm and ArgoCD
- ☁️ **Integrated Monitoring** – Prometheus, Loki, and OpenTelemetry installed and connected to Grafana Cloud
- 🔐 **Secure CI/CD** – GitHub Actions with OIDC-based IAM authentication (no long-lived secrets)

---

## 🔄 GitOps with ArgoCD

The EKS cluster is integrated with [ArgoCD](https://argo-cd.readthedocs.io/) for GitOps-based deployment. After bootstrapping the cluster, ArgoCD is deployed via Helm and synchronized with the applications defined in:


## ⚙️ CI/CD with GitHub Actions

This repository supports secure CI/CD pipelines using GitHub Actions with OpenID Connect (OIDC) to assume IAM roles without needing static secrets.

Pipeline steps include:

- ✅ Linting and testing the code
- 🐳 Building and pushing Docker images to Amazon ECR
- 🚀 Updating Helm chart versions and triggering ArgoCD sync
- 🔏 Signing images with Cosign
- 🔍 Verifying image signatures with Kyverno

---

## 📌 TODO

- [ ] Add documentation for each module in `modules/`
- [ ] Add backend configuration example (S3 + DynamoDB for state locking)
- [ ] Add `pre-commit` hooks for Terraform and HCL validation
- [ ] Add CI pipeline to validate infrastructure changes via `terraform validate` and `terragrunt hclfmt`

---