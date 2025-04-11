include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/github-actions-oidc"
}

dependencies {
  paths = ["../vpc", "../eks", "../ingress", "../argocd"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  region            = local.env.locals.region
}