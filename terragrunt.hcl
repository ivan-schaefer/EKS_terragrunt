terraform {
  source = "./modules/${path_relative_to_include()}"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "eks-terraform-state-eu-central-1"
    key            = "eks/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    use_lockfile = true
  }
}

