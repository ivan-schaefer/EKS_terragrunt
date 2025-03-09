include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/autoscaler"
}

dependencies {
  paths = ["../eks"]
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
}

