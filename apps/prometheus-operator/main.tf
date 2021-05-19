provider "kubernetes" {
  config_path = "~/.kube/config"
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