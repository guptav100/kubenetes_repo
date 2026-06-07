variable "app_name" {
  type    = string
  default = "nginx-gke"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "storage_size" {
  type    = string
  default = "10Gi"
}

variable "namespace" {
  type    = string
  default = "default"
}

module "common" {
  source             = "../common"
  app_name           = var.app_name
  namespace          = var.namespace
  replicas           = var.replicas
  storage_size       = var.storage_size
  storage_class_name = "standard-rwo" # GKE default CSI driver
}

output "service_load_balancer_ip" {
  value = module.common.service_load_balancer_info[0].ip
}
