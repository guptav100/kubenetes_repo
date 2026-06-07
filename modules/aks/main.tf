variable "app_name" {
  type    = string
  default = "nginx-aks"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "storage_size" {
  type    = string
  default = "5Gi"
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
          image = "mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine"
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
            claim_name = kubernetes_persistent_volume_claim.azure_disk.metadata[0].name
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

resource "kubernetes_persistent_volume_claim" "azure_disk" {
  metadata {
    name      = "${var.app_name}-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "managed-csi"
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

output "service_load_balancer_ip" {
  value = kubernetes_service.nginx_svc.status[0].load_balancer[0].ingress[0].ip
}
