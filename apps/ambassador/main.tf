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


resource "kubernetes_namespace" "ambassador" {
  metadata {
    annotations = {
      name = "ambassador"
    }
    labels = {
      namespace = "ambassador"
      product = "aes"
      }
    name = "ambassador"
  }
}

resource "kubernetes_manifest" "service_account_ambassador"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "v1"
  "kind" = "ServiceAccount"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador"
    "namespace" = "ambassador"
  }
}

}

resource "kubernetes_manifest" "ambassador_cluster_role"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador"
  }
  "aggregationRule" = {
    "clusterRoleSelectors" = [
      {
        "matchLabels" = {
          "rbac.getambassador.io/role-group" = "ambassador"
        }
      }
    ]
  }
  #"rules" = [""]
}

}


resource "kubernetes_manifest" "cluster_role_binding_ambassador"{
  depends_on = [kubernetes_namespace.ambassador, kubernetes_manifest.ambassador_cluster_role, kubernetes_manifest.service_account_ambassador]
  manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRoleBinding"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador"
  }
  "roleRef" = {
    "apiGroup" = "rbac.authorization.k8s.io"
    "kind" = "ClusterRole"
    "name" = "ambassador"
  }
  "subjects" = [
    {
      "kind" = "ServiceAccount"
      "name" = "ambassador"
      "namespace" = "ambassador"
    },
  ]
}

}

resource "kubernetes_manifest" "cluster_role_ambassador_projects"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-projects"
  }
  "rules" = [
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "secrets",
        "services",
      ]
      "verbs" = [
        "get",
        "list",
        "create",
        "patch",
        "delete",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "apps",
      ]
      "resources" = [
        "deployments",
      ]
      "verbs" = [
        "get",
        "list",
        "create",
        "patch",
        "delete",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "batch",
      ]
      "resources" = [
        "jobs",
      ]
      "verbs" = [
        "get",
        "list",
        "create",
        "patch",
        "delete",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "pods",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "pods/log",
      ]
      "verbs" = [
        "get",
      ]
    },
  ]
}

}

resource "kubernetes_manifest" "cluster_role_binding_ambassador_projects"{
  depends_on = [kubernetes_namespace.ambassador,kubernetes_manifest.cluster_role_ambassador_projects, kubernetes_manifest.service_account_ambassador]
  manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRoleBinding"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-projects"
  }
  "roleRef" = {
    "apiGroup" = "rbac.authorization.k8s.io"
    "kind" = "ClusterRole"
    "name" = "ambassador-projects"
  }
  "subjects" = [
    {
      "kind" = "ServiceAccount"
      "name" = "ambassador"
      "namespace" = "ambassador"
    },
  ]
}

}

resource "kubernetes_service" "ambassador_redis_service"{
  depends_on = [kubernetes_namespace.ambassador]
  metadata {
    annotations = {
      "a8r.io/bugs" = "https://github.com/datawire/ambassador/issues"
      "a8r.io/chat" = "http://a8r.io/Slack"
      "a8r.io/dependencies" = "None"
      "a8r.io/description" = "The Ambassador Edge Stack Redis store for auth and rate limiting, among other things."
      "a8r.io/documentation" = "https://www.getambassador.io/docs/edge-stack/latest/"
      "a8r.io/owner" = "Ambassador Labs"
      "a8r.io/repository" = "github.com/datawire/ambassador"
      "a8r.io/support" = "https://www.getambassador.io/about-us/support/"
    }
    labels = {
      "product" = "aes"
    }
    name = "ambassador-redis"
    namespace = "ambassador"
  }
  spec {
    port {
        port = 6379
        target_port = 6379
      }
    selector = {
      "service" = "ambassador-redis"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "ambassador_redis_deployment"{
  depends_on = [kubernetes_namespace.ambassador]
  metadata {
    labels = {
      "product" = "aes"
    }
    name = "ambassador-redis"
    namespace = "ambassador"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        service = "ambassador-redis"
      }
    }
    template {
      metadata {
        labels = {
          "service" = "ambassador-redis"
        }
      }
      spec {
        container {
            image = "redis:5.0.1"
            image_pull_policy = "IfNotPresent"
            name = "redis"
          }
        restart_policy = "Always"
      }
    }
  }
}


resource "kubernetes_manifest" "ambassador_edge_stack_ratelimit"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "getambassador.io/v2"
  "kind" = "RateLimitService"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-edge-stack-ratelimit"
    "namespace" = "ambassador"
  }
  "spec" = {
    "service" = "127.0.0.1:8500"
  }
}

}

resource "kubernetes_manifest" "ambassador_edge_stack_auth"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "getambassador.io/v2"
  "kind" = "AuthService"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-edge-stack-auth"
    "namespace" = "ambassador"
  }
  "spec" = {
    "allow_request_body" = false
    "auth_service" = "127.0.0.1:8500"
    "proto" = "grpc"
    "status_on_error" = {
      "code" = 504
    }
  }
}

}

resource "kubernetes_manifest" "ambassador_edge_stack_secret"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "v1"
  "data" = {
    "license-key" = ""
  }
  "kind" = "Secret"
  "metadata" = {
    "name" = "ambassador-edge-stack"
    "namespace" = "ambassador"
  }
  "type" = "Opaque"
}

}

resource "kubernetes_manifest" "ambassador_devportal_map"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "getambassador.io/v2"
  "kind" = "Mapping"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-devportal"
    "namespace" = "ambassador"
  }
  "spec" = {
    "prefix" = "/docs/"
    "rewrite" = "/docs/"
    "service" = "127.0.0.1:8500"
  }
}

}

resource "kubernetes_manifest" "ambassador_devportal_assets_map"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "getambassador.io/v2"
  "kind" = "Mapping"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-devportal-assets"
    "namespace" = "ambassador"
  }
  "spec" = {
    "add_response_headers" = {
      "cache-control" = {
        "append" = false
        "value" = "public, max-age=3600, immutable"
      }
    }
    "prefix" = "/documentation/(assets|styles)/(.*)(.css)"
    "prefix_regex" = true
    "regex_rewrite" = {
      "pattern" = "/documentation/(.*)"
      "substitution" = "/docs/\\1"
    }
    "service" = "127.0.0.1:8500"
  }
}

}

resource "kubernetes_manifest" "ambassador_devportal_api_map"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "getambassador.io/v2"
  "kind" = "Mapping"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-devportal-api"
    "namespace" = "ambassador"
  }
  "spec" = {
    "prefix" = "/openapi/"
    "rewrite" = ""
    "service" = "127.0.0.1:8500"
  }
}

}

resource "kubernetes_service" "ambassador_service"{
  depends_on = [kubernetes_namespace.ambassador]
  metadata {
    annotations = {
      "a8r.io/bugs" = "https://github.com/datawire/ambassador/issues"
      "a8r.io/chat" = "http://a8r.io/Slack"
      "a8r.io/dependencies" = "ambassador-redis.ambassador"
      "a8r.io/description" = "The Ambassador Edge Stack goes beyond traditional API Gateways and Ingress Controllers with the advanced edge features needed to support developer self-service and full-cycle development."
      "a8r.io/documentation" = "https://www.getambassador.io/docs/edge-stack/latest/"
      "a8r.io/owner" = "Ambassador Labs"
      "a8r.io/repository" = "github.com/datawire/ambassador"
      "a8r.io/support" = "https://www.getambassador.io/about-us/support/"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "http"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "stack=testing,purpose=text,service-name=dev-elb"
    }
    labels = {
      "app.kubernetes.io/component" = "ambassador-service"
      "product" = "aes"
    }
    name = "ambassador"
    namespace = "ambassador"
  }
  spec {
    selector = {
      "service" = "ambassador"
    }
    port {
        name = "http"
        port = 80
        protocol = "TCP"
        target_port = 8080
      }
    port  {
        name = "https"
        port = 443
        protocol = "TCP"
        target_port = 8443
      }
    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "ambassador_deployment"{
    depends_on = [ kubernetes_namespace.ambassador]
  metadata {
    labels = {
      "product" = "aes"
    }
    name = "ambassador"
    namespace = "ambassador"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        service = "ambassador"
      }
    }
    strategy  {
      type = "RollingUpdate"
    }
    template {
      metadata {
        annotations = {
          "consul.hashicorp.com/connect-inject" = "false"
          "sidecar.istio.io/inject" = "false"
        }
        labels = {
          "app.kubernetes.io/managed-by" = "getambassador.io"
          "service" = "ambassador"
        }
      }
      spec {
        affinity  {
          pod_anti_affinity  {
            preferred_during_scheduling_ignored_during_execution {
                pod_affinity_term {
                  label_selector {
                    match_labels = {
                      service = "ambassador"
                    }
                  }
                  topology_key = "kubernetes.io/hostname"
                }
                weight = 100
              }
          }
        }
        container {
            env {
                name = "HOST_IP"
                value_from  {
                  field_ref  {
                    field_path = "status.hostIP"
                  }
                }
              }
            env  {
                name = "REDIS_URL"
                value = "ambassador-redis:6379"
              }
            env {
                name = "AMBASSADOR_NAMESPACE"
                value_from  {
                  field_ref  {
                    field_path = "metadata.namespace"
                  }
                }
              }
            env {
                name = "AMBASSADOR_DRAIN_TIME"
                value = 600
              }
            env {
                name = "AMBASSADOR_INTERNAL_URL"
                value = "https://127.0.0.1:8443"
              }
            env {
                name = "AMBASSADOR_URL"
                value = "https://ambassador.ambassador.svc.cluster.local"
              }
            env {
                name = "POLL_EVERY_SECS"
                value = 60
              }
            image = "docker.io/datawire/aes:1.13.9"
            image_pull_policy = "IfNotPresent"
            liveness_probe  {
              failure_threshold = 3
              http_get {
                path = "/ambassador/v0/check_alive"
                port = "admin"
              }
              initial_delay_seconds = 30
              period_seconds = 3
            }
            name = "aes"
            port {
                container_port = 8080
                name = "http"
              }
            port  {
                container_port = 8443
                name = "https"
              }
            port {
                container_port = 8877
                name = "admin"
              }

            readiness_probe {
              failure_threshold = 3
              http_get {
                path = "/ambassador/v0/check_ready"
                port = "admin"
              }
              initial_delay_seconds = 30
              period_seconds = 3
            }
            resources {
              limits = {
                cpu = "1000m"
                memory = "600Mi"
              }
              requests = {
                cpu = "200m"
                memory = "300Mi"
              }
            }
            security_context {
              allow_privilege_escalation = false
            }
            volume_mount {
                mount_path = "/tmp/ambassador-pod-info"
                name = "ambassador-pod-info"
                read_only = true
              }
            volume_mount  {
                mount_path = "/.config/ambassador"
                name = "ambassador-edge-stack-secrets"
                read_only = true
              }
          }
        dns_policy = "ClusterFirst"
        host_network = false
        restart_policy = "Always"
        security_context {
          run_as_user = 8888
        }
        service_account_name = "ambassador"
        termination_grace_period_seconds = 0
        volume {
            downward_api  {
              items {
                  field_ref  {
                    field_path = "metadata.labels"
                  }
                  path = "labels"
                }
            }
            name = "ambassador-pod-info"
          }
        volume {
            name = "ambassador-edge-stack-secrets"
            secret {
              secret_name = "ambassador-edge-stack"
            }
          }
      }
    }
  }
}

resource "kubernetes_service" "ambassador_admin_service"{
  depends_on = [kubernetes_namespace.ambassador]
  metadata {
    annotations = {
      "a8r.io/bugs" = "https://github.com/datawire/ambassador/issues"
      "a8r.io/chat" = "http://a8r.io/Slack"
      "a8r.io/dependencies" = "None"
      "a8r.io/description" = "The Ambassador Edge Stack admin service for internal use and health checks."
      "a8r.io/documentation" = "https://www.getambassador.io/docs/edge-stack/latest/"
      "a8r.io/owner" = "Ambassador Labs"
      "a8r.io/repository" = "github.com/datawire/ambassador"
      "a8r.io/support" = "https://www.getambassador.io/about-us/support/"
    }
    labels = {
      "product" = "aes"
      "service" = "ambassador-admin"
    }
    name = "ambassador-admin"
    namespace = "ambassador"
  }
  spec {
    port {
      name = "ambassador-admin"
      port = 8877
      protocol = "TCP"
      target_port = "admin"
      }
    port  {
      name = "ambassador-snapshot"
      port = 8005
      protocol = "TCP"
      target_port = 8005
      }

    selector = {
      "service" = "ambassador"
    }
    type = "ClusterIP"
  }
}


resource "kubernetes_manifest" "ambassador_crd_cluster_role"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
      "rbac.getambassador.io/role-group" = "ambassador"
    }
    "name" = "ambassador-crd"
  }
  "rules" = [
    {
      "apiGroups" = [
        "apiextensions.k8s.io",
      ]
      "resources" = [
        "customresourcedefinitions",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
        "delete",
      ]
    },
  ]
}


}

resource "kubernetes_manifest" "ambassador_watch_cluster_role"{
  depends_on = [kubernetes_namespace.ambassador]
  manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
      "rbac.getambassador.io/role-group" = "ambassador"
    }
    "name" = "ambassador-watch"
  }
  "rules" = [
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "namespaces",
        "services",
        "secrets",
        "endpoints",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "getambassador.io",
      ]
      "resources" = [
        "*",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
        "update",
        "patch",
        "create",
        "delete",
      ]
    },
    {
      "apiGroups" = [
        "getambassador.io",
      ]
      "resources" = [
        "mappings/status",
      ]
      "verbs" = [
        "update",
      ]
    },
    {
      "apiGroups" = [
        "networking.internal.knative.dev",
      ]
      "resources" = [
        "clusteringresses",
        "ingresses",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "networking.x-k8s.io",
      ]
      "resources" = [
        "*",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "networking.internal.knative.dev",
      ]
      "resources" = [
        "ingresses/status",
        "clusteringresses/status",
      ]
      "verbs" = [
        "update",
      ]
    },
    {
      "apiGroups" = [
        "extensions",
        "networking.k8s.io",
      ]
      "resources" = [
        "ingresses",
        "ingressclasses",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
    {
      "apiGroups" = [
        "extensions",
        "networking.k8s.io",
      ]
      "resources" = [
        "ingresses/status",
      ]
      "verbs" = [
        "update",
      ]
    },
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "secrets",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
        "create",
        "update",
      ]
    },
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "events",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
        "create",
        "patch",
      ]
    },
    {
      "apiGroups" = [
        "coordination.k8s.io",
      ]
      "resources" = [
        "leases",
      ]
      "verbs" = [
        "get",
        "create",
        "update",
      ]
    },
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "endpoints",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
        "create",
        "update",
      ]
    },
  ]
}


}


resource "kubernetes_manifest" "ambassador_agent_cluster_role_binding"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest =  {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRoleBinding"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-agent"
  }
  "roleRef" = {
    "apiGroup" = "rbac.authorization.k8s.io"
    "kind" = "ClusterRole"
    "name" = "ambassador-agent"
  }
  "subjects" = [
    {
      "kind" = "ServiceAccount"
      "name" = "ambassador-agent"
      "namespace" = "ambassador"
    },
  ]
}

}

resource "kubernetes_manifest" "ambassador_agent_cluster_role"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-agent"
  }
  "aggregationRule" = {
    "clusterRoleSelectors" = [
      {
        "matchLabels" = {
          "rbac.getambassador.io/role-group" = "ambassador-agent"
        }
      },
    ]
  }
  #"rules" = []
}
}

resource "kubernetes_manifest" "ambassador_agent_pods_cluster_role"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
      "rbac.getambassador.io/role-group" = "ambassador-agent"
    }
    "name" = "ambassador-agent-pods"
  }
  "rules" = [
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "pods",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
  ]
}


}

resource "kubernetes_manifest" "ambassador_agent_rollouts_cluster_role"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
      "rbac.getambassador.io/role-group" = "ambassador-agent"
    }
    "name" = "ambassador-agent-rollouts"
  }
  "rules" = [
    {
      "apiGroups" = [
        "argoproj.io",
      ]
      "resources" = [
        "rollouts",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
  ]
}


}

resource "kubernetes_manifest" "ambassador_agent_applications_cluster_role"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "ClusterRole"
  "metadata" = {
    "labels" = {
      "product" = "aes"
      "rbac.getambassador.io/role-group" = "ambassador-agent"
    }
    "name" = "ambassador-agent-applications"
  }
  "rules" = [
    {
      "apiGroups" = [
        "argoproj.io",
      ]
      "resources" = [
        "applications",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
  ]
}

}

resource "kubernetes_manifest" "ambassador_agent_config_role"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest =  {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "Role"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-agent-config"
    "namespace" = "ambassador"
  }
  "rules" = [
    {
      "apiGroups" = [
        "",
      ]
      "resources" = [
        "configmaps",
      ]
      "verbs" = [
        "get",
        "list",
        "watch",
      ]
    },
  ]
}

}

resource "kubernetes_manifest" "ambassador_agent_service_account"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
  "apiVersion" = "v1"
  "kind" = "ServiceAccount"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-agent"
    "namespace" = "ambassador"
  }
}

}


resource "kubernetes_manifest" "ambassador_agent_config_role_binding"{
    depends_on = [ kubernetes_namespace.ambassador, kubernetes_manifest.ambassador_agent_service_account, kubernetes_manifest.ambassador_agent_config_role ]
    manifest = {
  "apiVersion" = "rbac.authorization.k8s.io/v1"
  "kind" = "RoleBinding"
  "metadata" = {
    "labels" = {
      "product" = "aes"
    }
    "name" = "ambassador-agent-config"
    "namespace" = "ambassador"
  }
  "roleRef" = {
    "apiGroup" = "rbac.authorization.k8s.io"
    "kind" = "Role"
    "name" = "ambassador-agent-config"
  }
  "subjects" = [
    {
      "kind" = "ServiceAccount"
      "name" = "ambassador-agent"
      "namespace" = "ambassador"
    },
  ]
}

}

resource "kubernetes_manifest" "ambassador_agent_deployment"{
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
  "apiVersion" = "apps/v1"
  "kind" = "Deployment"
  "metadata" = {
    "labels" = {
      "app.kubernetes.io/instance" = "ambassador"
      "app.kubernetes.io/name" = "ambassador-agent"
    }
    "name" = "ambassador-agent"
    "namespace" = "ambassador"
  }
  "spec" = {
    "replicas" = 1
    "selector" = {
      "matchLabels" = {
        "app.kubernetes.io/instance" = "ambassador"
        "app.kubernetes.io/name" = "ambassador-agent"
      }
    }
    "template" = {
      "metadata" = {
        "labels" = {
          "app.kubernetes.io/instance" = "ambassador"
          "app.kubernetes.io/name" = "ambassador-agent"
        }
      }
      "spec" = {
        "containers" = [
          {
            "command" = [
              "agent",
            ]
            "env" = [
              {
                "name" = "AGENT_NAMESPACE"
                "valueFrom" = {
                  "fieldRef" = {
                    "fieldPath" = "metadata.namespace"
                  }
                }
              },
              {
                "name" = "AGENT_CONFIG_RESOURCE_NAME"
                "value" = "ambassador-agent-cloud-token"
              },
              {
                "name" = "RPC_CONNECTION_ADDRESS"
                "value" = "https://app.getambassador.io/"
              },
              {
                "name" = "AES_SNAPSHOT_URL"
                "value" = "http://ambassador-admin.ambassador:8005/snapshot-external"
              },
            ]
            "image" = "docker.io/datawire/aes:1.13.9"
            "imagePullPolicy" = "IfNotPresent"
            "name" = "agent"
          },
        ]
        "serviceAccountName" = "ambassador-agent"
      }
    }
  }
}

}

resource "kubernetes_manifest" "ambassador_host"{
    depends_on = [ kubernetes_namespace.ambassador]
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
    depends_on = [ kubernetes_namespace.ambassador]
    manifest = {
        "apiVersion" = "getambassador.io/v2"
        "kind" = "Module"
        "metadata" = {
            "name" =  "ambassador"
            "namespace" =  "ambassador"
        }
        "spec" = {
            "config" = {
                "xff_num_trusted_hops" = 1
                "use_remote_address" = "false"
            }
        }
    }
}
