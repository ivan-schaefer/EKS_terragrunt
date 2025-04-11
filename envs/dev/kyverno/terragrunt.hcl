include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/=kyverno"
}

dependencies {
  paths = ["../vpc", "../eks", "../ingress", "../argocd", "../monitoring"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
}
