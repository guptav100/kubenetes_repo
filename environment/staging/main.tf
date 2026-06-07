terraform {
  required_version = ">= 1.0.0"

  # Uncomment and configure your preferred backend
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "staging/kubernetes.tfstate"
  #   region = "us-east-1"
  # }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

variable "kube_config" {
  type        = string
  default     = "~/.kube/config"
  description = "Path to the kubeconfig file"
}

provider "kubernetes" {
  config_path = var.kube_config
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
