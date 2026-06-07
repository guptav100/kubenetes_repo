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
  # Configuration depends on how the cluster is accessed (kubeconfig, tokens, etc.)
  # For dev, we might use the current context
  config_path = "~/.kube/config"
}

module "aks_app" {
  source       = "../../modules/aks"
  app_name     = "dev-nginx-aks"
  replicas     = 1
  storage_size = "1Gi"
}

module "eks_app" {
  source       = "../../modules/eks"
  app_name     = "dev-nginx-eks"
  replicas     = 1
  storage_size = "1Gi"
}

module "gke_app" {
  source       = "../../modules/gke"
  app_name     = "dev-nginx-gke"
  replicas     = 1
  storage_size = "1Gi"
}
