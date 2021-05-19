terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "0.1.6"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}


module "flux"{
    source = "./apps/fluxcd"
    target_path = var.target_path
    github_owner = var.github_owner
    repository_name = var.repository_name
    branch = var.branch
    flux_token  = var.flux_token
    bucket       = var.infra_bucket[var.env]
    key          = var.infra_file[var.env]
    region =  var.region

}


module "prometheus-operator"{
    source = "./apps/prometheus-operator"
}