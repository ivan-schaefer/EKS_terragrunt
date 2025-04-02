include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/ingress"
}

dependencies {
  paths = ["../vpc", "../eks"]
}

inputs = {
  cluster_name         = "eks-cluster"
}
