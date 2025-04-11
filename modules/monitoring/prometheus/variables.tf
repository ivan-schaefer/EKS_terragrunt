variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "grafana_cloud_prometheus_url" {
  type = string
}

variable "grafana_cloud_username" {
  type = string
}

variable "grafana_cloud_api_key" {
  type      = string
  sensitive = true
}

variable "secret_name" {
  type = string
}

variable "cluster_name" {
  type = string
}