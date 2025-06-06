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
  cluster_name         = "eks-cluster"
}
