variable "app_name" {
  type    = string
  default = "nginx-eks"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "storage_size" {
  type    = string
  default = "4Gi"
}

variable "namespace" {
  type    = string
  default = "default"
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "${var.app_name}-ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  parameters = {
    type = "gp3"
  }
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
}

module "common" {
  source             = "../common"
  app_name           = var.app_name
  namespace          = var.namespace
  replicas           = var.replicas
  storage_size       = var.storage_size
  storage_class_name = kubernetes_storage_class.ebs_sc.metadata[0].name
}

output "service_load_balancer_hostname" {
  value = module.common.service_load_balancer_info[0].hostname
}
