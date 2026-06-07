variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Kubernetes namespace"
}

variable "replicas" {
  type        = number
  default     = 2
  description = "Number of pod replicas"
}

variable "image" {
  type        = string
  default     = "nginx:1.25.3-alpine"
  description = "Container image to deploy"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "storage_size" {
  type    = string
  default = "5Gi"
}

variable "storage_class_name" {
  type        = string
  description = "Platform specific storage class name"
}

variable "cpu_request" {
  type    = string
  default = "100m"
}

variable "mem_request" {
  type    = string
  default = "128Mi"
}

variable "cpu_limit" {
  type    = string
  default = "500m"
}

variable "mem_limit" {
  type    = string
  default = "256Mi"
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = var.image
          name  = "app"

          port {
            container_port = var.container_port
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.mem_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.mem_limit
            }
          }

          volume_mount {
            name       = "storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.this.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "${var.app_name}-svc"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = var.container_port
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "this" {
  metadata {
    name      = "${var.app_name}-pvc"
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

output "service_load_balancer_info" {
  value = kubernetes_service.this.status[0].load_balancer[0].ingress
}
