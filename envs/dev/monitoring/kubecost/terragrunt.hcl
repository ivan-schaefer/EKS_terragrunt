include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/monitoring/kubecost"
}

dependencies {
  paths = ["../../vpc", "../../eks", "../../ingress", "../../argocd", "../../prometheus"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  namespace              = "monitoring"
  cluster_name           = local.env.locals.cluster_name
}

