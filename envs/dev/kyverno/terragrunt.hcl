include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/kyverno"
}

dependencies {
  paths = ["../vpc", "../eks", "../ingress", "../argocd", "../monitoring/prometheus"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  cluster_name = local.env.locals.cluster_name
}
