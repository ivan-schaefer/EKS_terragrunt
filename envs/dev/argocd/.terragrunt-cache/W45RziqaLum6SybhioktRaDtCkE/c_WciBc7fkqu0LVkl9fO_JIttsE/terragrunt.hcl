include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/argo-cd"
}

dependencies {
  paths = ["../vpc", "../eks", "../ingress"]
}

inputs = {
  cluster_name         = "eks-cluster"
}
