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
  config_path = "~/.kube/config" # In staging, this might be a specific context or service account
}

module "aks_app" {
  source       = "../../modules/aks"
  app_name     = "staging-nginx-aks"
  replicas     = 2
  storage_size = "5Gi"
}

module "eks_app" {
  source       = "../../modules/eks"
  app_name     = "staging-nginx-eks"
  replicas     = 2
  storage_size = "5Gi"
}

module "gke_app" {
  source       = "../../modules/gke"
  app_name     = "staging-nginx-gke"
  replicas     = 2
  storage_size = "5Gi"
}
