include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/node-group"
}

inputs = {
  cluster_name   = "eks-demo"
  region         = "eu-central-1"
  nodes_name     = "eks-nodes"

  instance_type = "t3.medium"
  desired_size  = 2
  min_size      = 1
  max_size      = 5
}
