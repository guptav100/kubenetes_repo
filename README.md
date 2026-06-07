# Terraform Kubernetes Project

This repository contains Terraform modules and environment configurations for deploying Nginx applications across different Kubernetes platforms (AKS, EKS, and GKE).

## Architecture

- **`modules/`**: Contains reusable infrastructure components.
    - **`common/`**: The base module for Deployment, Service, and PVC resources.
    - **`aks/`, `eks/`, `gke/`**: Platform-specific wrappers that provide the correct storage classes and annotations.
- **`environment/`**: Contains environment-specific configurations (Dev, Staging, Prod).

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0.0)
- Access to a Kubernetes cluster (AKS, EKS, or GKE).
- A configured `kubeconfig` file (default: `~/.kube/config`).

## How to Deploy

1. Navigate to the desired environment directory:
   ```bash
   cd environment/dev
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. (Optional) Provide your kubeconfig path if not using the default:
   ```bash
   terraform plan -var="kube_config=/path/to/your/config"
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Best Practices Implemented

- **DRY (Don't Repeat Yourself)**: Shared logic is centralized in the `common` module.
- **Resource Constraints**: All containers have CPU/Memory requests and limits.
- **CI/CD**: GitHub Actions workflow included for automated validation.
- **Security**: Specific container image tags are used instead of `latest`.
