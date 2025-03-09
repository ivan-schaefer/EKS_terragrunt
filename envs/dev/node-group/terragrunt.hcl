include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/node-group"
}

dependencies {
  paths = ["../eks", "../vpc"]
}

inputs = {
  cluster_name  = dependency.eks.outputs.cluster_name
  vpc_id        = dependency.vpc.outputs.vpc_id
  subnets       = dependency.vpc.outputs.private_subnets
  instance_type = "t3.medium"
  desired_size  = 2
  min_size      = 1
  max_size      = 5
}
