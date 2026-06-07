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

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ebs_claim.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_svc" {
  metadata {
    name      = "${var.app_name}-svc"
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "ebs_claim" {
  metadata {
    name      = "${var.app_name}-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.ebs_sc.metadata[0].name
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
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

output "service_load_balancer_hostname" {
  value = kubernetes_service.nginx_svc.status[0].load_balancer[0].ingress[0].hostname
}
