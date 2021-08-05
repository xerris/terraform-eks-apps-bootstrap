terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version       = "2.2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.10.0"
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

resource "helm_release" "ambassador" {
  name       = "ambassador-elb"
  repository = "https://app.getambassador.io"
  chart      = "datawire/ambassador"
  #version    =  "6.7.11"#"6.3.5"
  namespace  = "ambassador"
  create_namespace = true
  #repository = "https://getambassador.io/"
  timeout    = 3600
  values = [
    "${file("apps/ambassador/ambassador.yaml")}"
  ]
}
