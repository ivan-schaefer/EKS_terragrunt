include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/monitoring"
}

dependencies {
  paths = ["../vpc", "../eks", "../ingress", "../argocd"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  namespace = "monitoring"
  secret_name = "kubepromsecret"
  cluster_name = local.env.locals.cluster_name
}

