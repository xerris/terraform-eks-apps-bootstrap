terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "0.2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    annotations = {
      name = "prometheus"
    }
    labels = {
      namespace = "prometheus"
      }
    name = "prometheus"
  }
}

resource "helm_release" "prometheus-operator" {
  depends_on = [kubernetes_namespace.prometheus]
  name = "prometheus-operator"
  version   = "9.3.2"
  chart      = "prometheus-operator"
  repository = "https://charts.helm.sh/stable/"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  timeout    = 3600
  dependency_update = true
  values = []
  set {
    name  = "cluster.enabled"
    value = "true"
  }
  set {
    name  = "metrics.enabled"
    value = "true"
  }
}

resource "kubernetes_namespace" "custom-metrics" {
  metadata {
    annotations = {
      name = "custom-metrics"
    }
    labels = {
      namespace = "custom-metrics"
      }
    name = "custom-metrics"
  }
}

resource "helm_release" "prometheus-adaptor" {
  depends_on = [kubernetes_namespace.custom-metrics,helm_release.prometheus-operator ]
  name = "prometheus-adaptor"
  version   = "0.8.4"
  chart      = "prometheus-adapter"
  repository = "https://prometheus-community.github.io/helm-charts/"
  namespace  = kubernetes_namespace.custom-metrics.metadata[0].name
  timeout    = 3600
  dependency_update = true
  values = []
  set {
    name  = "prometheus.url"
    value = "http://prometheus-operator-operator"
  }
  set {
    name  = "prometheus.port"
    value = "9090"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

}
