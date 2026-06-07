terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  # In prod, you'd typically use a more secure auth method
  config_path = "~/.kube/config"
}

module "aks_app" {
  source       = "../../modules/aks"
  app_name     = "prod-nginx-aks"
  replicas     = 3
  storage_size = "10Gi"
}

module "eks_app" {
  source       = "../../modules/eks"
  app_name     = "prod-nginx-eks"
  replicas     = 3
  storage_size = "10Gi"
}

module "gke_app" {
  source       = "../../modules/gke"
  app_name     = "prod-nginx-gke"
  replicas     = 3
  storage_size = "10Gi"
}
