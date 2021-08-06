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
    experiments {
        manifest_resource = true
    }
    config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "ambassador" {
  name       = "ambassador-elb"
  chart      = "https://app.getambassador.io/helm/ambassador-6.3.5.tgz" #ambassador-operator-0.3.0.tgz
  namespace  = "ambassador"
  create_namespace = true
  timeout    = 3600
  values = [
    "${file("apps/ambassador/ambassador.yaml")}"
  ]
}

resource "kubernetes_manifest" "ambassador_host"{
    depends_on = [ helm_release.ambassador]
    manifest = {
        "apiVersion" = "getambassador.io/v2"
        "kind" = "Host"
        "metadata" = {
            "name" =  "ambassador"
            "namespace" =  "ambassador"
        }
        "spec" = {
            "hostname" = "*"
            "selector" = {
                "matchLabels" = {
                    "hostname" = "wildcard"
                }
            }
            "acmeProvider" = {
                "authority" = "none"
            }
            "requestPolicy" = {
                "insecure" = {
                    "action" = "Route"
                }
            }
        }
    }
}

resource "kubernetes_manifest" "ambassador_module"{
    depends_on = [ helm_release.ambassador]
    manifest = {
        "apiVersion" = "getambassador.io/v2"
        "kind" = "Module"
        "metadata" = {
            "name" =  "ambassador"
            "namespace" =  "ambassador"
        }
        "spec" = {
            "config" = {
                "xff_num_trusted_hops" = "1"
                "use_remote_address" = "false"
            }
        }
    }
}