# 📦 VPC Module

This module is responsible for provisioning the base networking infrastructure (VPC, subnets, gateways, etc.) required by the EKS cluster and related services.

It is built on top of the official [terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/terraform-aws-vpc) and wrapped with a Terragrunt configuration for easy reuse across multiple environments.

---

## 🌐 Features

- Creates a **VPC** with a configurable CIDR block
- Creates **public and private subnets** across multiple Availability Zones
- Deploys an **Internet Gateway** and optional **NAT Gateway(s)**
- Supports **single NAT gateway** mode to reduce costs
- Optionally disables default **security groups** and **NACLs**
- Outputs subnet IDs and availability zones for use in other modules

---

## 📥 Inputs

| Name                           | Description                                       | Type             | Default  | Required |
|--------------------------------|---------------------------------------------------|------------------|----------|----------|
| `vpc_name`                     | Name of the VPC                                   | `string`         | n/a      | yes      |
| `cidr`                         | CIDR block for the VPC                            | `string`         | n/a      | yes      |
| `availability_zones`           | List of availability zones                        | `list(string)`   | n/a      | yes      |
| `private_subnets`              | List of private subnet CIDRs                      | `list(string)`   | n/a      | yes      |
| `public_subnets`               | List of public subnet CIDRs                       | `list(string)`   | n/a      | yes      |
| `enable_nat_gateway`           | Whether to enable NAT gateway(s)                  | `bool`           | `true`   | no       |
| `single_nat_gateway`           | Use one NAT gateway across all AZs                | `bool`           | `true`   | no       |
| `manage_default_network_acl`   | Whether to manage default NACL                    | `bool`           | `false`  | no       |
| `manage_default_security_group`| Whether to manage default SG                      | `bool`           | `false`  | no       |

---

## 📤 Outputs

| Name             | Description                        |
|------------------|------------------------------------|
| `vpc_id`         | ID of the created VPC              |
| `private_subnets`| List of private subnet IDs         |
| `public_subnets` | List of public subnet IDs          |
| `azs`            | List of availability zones used    |
| `vpc_cidr_block` | Alias for CIDR block of the VPC    |

---

## 🧩 Usage with Terragrunt

```hcl
terraform {
  source = "../../modules/vpc"
}

inputs = {
  cidr               = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  vpc_name           = "eks-vpc"
  environment        = "dev"
  cluster_name       = "eks-cluster'
}
```

---

## 📝 Notes

- This module **does not configure routing rules, NACLs, or SGs directly** — use dedicated modules in `networking/` for that.
- Can be extended with additional tags using `tags` variable from the base module.
- Outputs are used as dependencies by EKS, ALB, and other networking components.