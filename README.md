# EKS Infrastructure with Terragrunt
<p align="center">
  <img src="https://skillicons.dev/icons?i=aws,terraform,kubernetes,prometheus,grafana&perline=5" alt="CI Tools" />
  <img src="https://raw.githubusercontent.com/cert-manager/cert-manager/d53c0b9270f8cd90d908460d69502694e1838f5f/logo/logo-small.png" alt="Helm Logo" height="48" style="margin-left: 6px;" />
</p>
This repository contains infrastructure code for deploying and managing an AWS Elastic Kubernetes Service (EKS) cluster using [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/). The structure is modular, DRY-compliant, and supports multiple environments and AWS accounts.

## 📁 Project Structure


<pre>
.
├── envs                             # Environment-specific configurations (e.g. dev, staging, prod)
│   └── dev                          # Development environment
│       ├── dev.hcl                  # Shared variables and inputs for the dev environment
│       ├── argocd                   # ArgoCD installation and setup
│       ├── certmanager              # cert-manager deployment and DNS/ACME issuer configuration
│       ├── eks                      # EKS cluster definition and configuration
│       ├── github-actions-oidc      # OIDC integration for GitHub Actions (IAM roles for CI/CD)
│       ├── ingress                  # ALB Ingress Controller and Ingress resources
│       ├── kyverno                  # Kyverno policies and admission controller
│       ├── monitoring               # Monitoring stack (metrics, logs, tracing, cost)
│       │   ├── kubecost             # Kubecost setup for cost monitoring and allocation
│       │   ├── loki                 # Loki deployment (log collection pipeline)
│       │   ├── prometheus           # Prometheus stack with remote write to Grafana Cloud
│       │   └── tempo                # OpenTelemetry Collector for tracing to Grafana Tempo
│       ├── networking               # Custom VPC-level resources
│       │   ├── network_acls         # Network ACL rules (public/private)
│       │   └── security_groups      # Custom security groups for ALB, EKS nodes, etc.
│       └── vpc                      # VPC and subnets module (core networking)
├── modules                          # Reusable infrastructure modules
│   ├── argocd                       # ArgoCD Helm chart wrapper
│   ├── certmanager                  # cert-manager chart with IAM roles
│   ├── eks                          # EKS cluster creation via terraform-aws-eks
│   ├── github-actions-oidc          # OIDC setup for GitHub Actions CI/CD
│   ├── ingress                      # AWS Load Balancer Controller Helm chart
│   ├── kyverno                      # Kyverno + base policies
│   │   ├── policies                 # Prebuilt policies (PSS, CIS, Cosign, Trivy)
│   ├── monitoring                   # Monitoring tools organized by function
│   │   ├── kubecost                 # Helm chart for cost monitoring
│   │   ├── loki                     # Helm chart for log shipping to Grafana
│   │   ├── prometheus               # Prometheus Helm chart and remote write config
│   │   └── tempo                    # OpenTelemetry Collector and trace exporter
│   ├── networking                   # Custom VPC resources
│   │   ├── network_acls             # NACL configuration module
│   │   └── security_groups          # SGs for EKS nodes, ALB, etc.
│   └── vpc                          # AWS VPC module wrapper (terraform-aws-modules/vpc/aws)
└── terragrunt.hcl                   # Root Terragrunt configuration (provider config, remote state)


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
Do not forget to get you password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -
```

## ⚙️ CI/CD with GitHub Actions

This repository supports secure CI/CD pipelines using GitHub Actions with OpenID Connect (OIDC) to assume IAM roles without needing static secrets.


## 📊 Grafana Connection

All metrics, logs, and traces are collected and sent to **Grafana Cloud**.

To use the monitoring stack:

1. 📋 **Sign up** for a free Grafana Cloud account: https://grafana.com/signup/
2. ⚙️ After creating your stack, go to **Connections → Kubernetes** in the Grafana Cloud UI.
3. 🔑 Copy the required credentials:
   - **Prometheus remote_write endpoint** and API key
   - **Loki push endpoint** and API key
   - **Tempo endpoint** and API key
4. 🔐 Store them in your secrets manager (e.g., GitHub Actions, SSM Parameter Store, or Kubernetes secrets).
5. ✅ Apply the configuration — metrics and logs will start flowing to your Grafana dashboards.

> This setup allows full observability of your EKS cluster using Grafana's managed backend for Prometheus, Loki, and Tempo.


## 📌 TODO

- [✅] Add Security Groups and NACLs for ALB and nodes
- [✅] Integrate Kyverno
- [✅] Add Loki + Fluent Bit for log shipping
- [✅] Add OpenTelemetry + Tempo for tracing
- [✅] Add Kubecost for cost monitoring
- [50%] Add Cert-Manager and enable TLS on Ingress
- [ ] Add Trivio Operator
- [ ] Add Istion service mash with TLS
- [ ] Add documentation for each module in `modules/`
