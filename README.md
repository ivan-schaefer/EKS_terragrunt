# EKS Infrastructure with Terragrunt
[![My Skills](https://skillicons.dev/icons?i=aws,terraform,kubernetes,prometheus,grafana&perline=5)](https://skillicons.dev)

This repository contains infrastructure code for deploying and managing an AWS Elastic Kubernetes Service (EKS) cluster using [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/). The structure is modular, DRY-compliant, and supports multiple environments and AWS accounts.

## 📁 Project Structure


<pre>
.
├── envs/                            # Environment configurations
│   ├── dev/                         # Development environment
│       ├── eks/                     # EKS configuration for dev
│       ├── monitoring/              # Monitoring stack (Prometheus, etc.)
│       ├── alb-controller/          # AWS Load Balancer Controller
│       ├── argocd/                  # ArgoCD installation
│       ├── vpc/                     # VPC definition
│       └── cicd/                    # OIDC provider for GitHub Actions
│
├── modules/                         # Reusable Terraform modules
│   ├── eks/                         # EKS module
│   ├── vpc/                         # VPC module
│   ├── alb-controller/              # ALB Controller module
│   ├── monitoring/                  # Monitoring stack (Prometheus, etc.)
│   ├── argocd/                      # ArgoCD module
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

terragrunt run-all init
terragrunt run-all validate
terragrunt run-all plan
terragrunt run-all apply 

```

If you want to create only 1 module

```bash
terragrunt run-all init --terragrunt-include-dir envs/dev/vpc
terragrunt run-all validate --terragrunt-include-dir envs/dev/vpc
terragrunt run-all plan --terragrunt-include-dir envs/dev/vpc
terragrunt run-all apply  --terragrunt-include-dir envs/dev/vpc
```

## 🛠 Features

- 🔁 **Modular Design** – Reusable Terraform modules for EKS, VPC, IAM, etc.
- 🌍 **Multi-environment & Multi-account** – Structured per environment (dev/prod) and AWS account
- ☸️ **EKS Cluster Bootstrapping** – Includes setup for core components via Helm and ArgoCD
- ☁️ **Integrated Monitoring** – Prometheus installed and connected to Grafana Cloud
- 🔐 **Secure CI/CD** – GitHub Actions with OIDC-based IAM authentication (no long-lived secrets)


## 🔄 GitOps with ArgoCD

The EKS cluster is integrated with [ArgoCD](https://argo-cd.readthedocs.io/) for GitOps-based deployment. After bootstrapping the cluster, ArgoCD is deployed via Helm, all you need is to create an application for ArgoCD


## ⚙️ CI/CD with GitHub Actions

This repository supports secure CI/CD pipelines using GitHub Actions with OpenID Connect (OIDC) to assume IAM roles without needing static secrets.


## 📌 TODO

- [ ] Add documentation for each module in `modules/`
- [ ] Add Security Groups and NACLs for ALB and nodes
- [ ] Integrate Kyverno with:
  - [ ] kube-bench
  - [ ] kube-hunter
  - [ ] Trivy Operator
- [ ] Add Loki + Fluent Bit for log shipping
- [ ] Add OpenTelemetry + Tempo for tracing
- [ ] Add Cert-Manager and enable TLS on Ingress
- [ ] Add Kubecost for cost monitoring
- [ ] Add Cilium CNI with eBPF observability
