include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/monitoring/loki"
}

dependencies {
  paths = ["../../vpc", "../../eks", "../../ingress", "../../argocd"]
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

inputs = {
  namespace              = "monitoring"
  secret_name            = "kubelokisecret"
  cluster_name           = local.env.locals.cluster_name
  grafana_cloud_loki_url = "https://logs-prod-012.grafana.net"


}

