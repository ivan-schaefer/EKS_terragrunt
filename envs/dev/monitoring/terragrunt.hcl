include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/monitoring"
}

dependencies {
  paths = ["../vpc", "../eks", "../ingress", "../argocd"]
}

inputs = {
  namespace = "monitoring"
  secret_name = "kubepromsecret"
}
