# 🌐 Networking Modules

This directory contains modules related to low-level networking configuration in the VPC used by the EKS cluster. These modules are separated from the core VPC module to allow finer control over access policies, security, and compliance.

---

## 📦 Modules Overview

### `network_acls`
Defines custom **Network ACLs** for public and private subnets.

- Public subnets: Allow HTTP/HTTPS inbound, all outbound
- Private subnets: Allow all from VPC CIDR, all outbound
- Applied to the relevant subnets via `subnet_ids` input

**Inputs:**
- `vpc_id` – ID of the VPC
- `vpc_cidr_block` – CIDR block of the VPC (used in private NACL)
- `public_subnet_ids` – IDs of public subnets
- `private_subnet_ids` – IDs of private subnets

**Outputs:**
- `public_nacl_id`
- `private_nacl_id`

---

### `security_groups`
Manages custom **Security Groups** used by:

- ALB (public-facing ingress)
- EKS nodes (private traffic)

Security groups are tagged appropriately to be discoverable by Karpenter and AWS Load Balancer Controller.

**Inputs:**
- `vpc_id`
- Any custom ingress/egress rule definitions
- Optional: ALB-specific and node-specific ports

**Outputs:**
- `alb_sg_id`
- `eks_node_sg_id`

---

## 🧩 Usage with Terragrunt

Reference these modules from the environment folder using:

```hcl
terraform {
  source = "../../modules/networking/network_acls" # or security_groups
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  vpc_id              = dependency.vpc.outputs.vpc_id
  public_subnet_ids   = dependency.vpc.outputs.public_subnets
  private_subnet_ids  = dependency.vpc.outputs.private_subnets
  vpc_cidr_block      = "10.0.0.0/16"
}
```

---

## 🔐 Notes

- Both modules assume the VPC has already been created.
- Security groups and NACLs are **not** managed by the base VPC module to enable separation of concerns.
- These modules follow AWS best practices for secure VPC network segmentation.

