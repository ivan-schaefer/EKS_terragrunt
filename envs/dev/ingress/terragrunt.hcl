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
  alb_role_name              = "alb-controller-role"
  alb_extra_permission_name  = "alb-extra-permissions"
  alb_sa_name                = "aws-load-balancer-controller"
  alb_ns                     = "kube-system"
}