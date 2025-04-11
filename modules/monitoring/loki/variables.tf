variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "grafana_cloud_user" {
  type = string
}

variable "secret_name" {
  type    = string
  default = "grafana-cloud-logs"
}

variable "grafana_cloud_api_key" {
  type      = string
  sensitive = true
}

variable "grafana_cloud_loki_url" {
  type = string
}

variable "cluster_name" {
  type = string
}