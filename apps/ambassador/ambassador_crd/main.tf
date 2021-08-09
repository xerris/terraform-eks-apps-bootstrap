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
####### CRD manifest Definitions ############

resource "kubernetes_manifest" "ambassador_authservice_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "authservices.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "AuthService"
      "listKind" = "AuthServiceList"
      "plural" = "authservices"
      "singular" = "authservice"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "AuthService is the Schema for the authservices API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "AuthServiceSpec defines the desired state of AuthService"
            "properties" = {
              "add_auth_headers" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "type" = "object"
              }
              "add_linkerd_headers" = {
                "type" = "boolean"
              }
              "allow_request_body" = {
                "type" = "boolean"
              }
              "allowed_authorization_headers" = {
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
              "allowed_request_headers" = {
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "auth_service" = {
                "type" = "string"
              }
              "failure_mode_allow" = {
                "type" = "boolean"
              }
              "include_body" = {
                "properties" = {
                  "allow_partial" = {
                    "type" = "boolean"
                  }
                  "max_bytes" = {
                    "description" = "These aren't pointer types because they are required."
                    "type" = "integer"
                  }
                }
                "required" = [
                  "allow_partial",
                  "max_bytes",
                ]
                "type" = "object"
              }
              "path_prefix" = {
                "type" = "string"
              }
              "proto" = {
                "enum" = [
                  "http",
                  "grpc",
                ]
                "type" = "string"
              }
              "protocol_version" = {
                "enum" = [
                  "v2",
                  "v3",
                ]
                "type" = "string"
              }
              "status_on_error" = {
                "description" = "Why isn't this just an int??"
                "properties" = {
                  "code" = {
                    "type" = "integer"
                  }
                }
                "type" = "object"
              }
              "timeout_ms" = {
                "type" = "integer"
              }
              "tls" = {
                "description" = "BoolOrString is a type that can hold a Boolean or a string."
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "boolean"
                  },
                ]
              }
            }
            "required" = [
              "auth_service",
            ]
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
  }

}

resource "kubernetes_manifest" "consul_resolver_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "consulresolvers.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "ConsulResolver"
      "listKind" = "ConsulResolverList"
      "plural" = "consulresolvers"
      "singular" = "consulresolver"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "ConsulResolver is the Schema for the ConsulResolver API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "ConsulResolver tells Ambassador to use Consul to resolve services. In addition to the AmbassadorID, it needs information about which Consul server and DC to use."
            "properties" = {
              "address" = {
                "type" = "string"
              }
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "datacenter" = {
                "type" = "string"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "dev_portals_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "devportals.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "DevPortal"
      "listKind" = "DevPortalList"
      "plural" = "devportals"
      "singular" = "devportal"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = <<-EOT
        DevPortal is the Schema for the DevPortals API
         DevPortal resources specify the `what` and `how` is shown in a DevPortal:
         * `what` is in a DevPortal can be controlled with   - a `selector`, that can be used for filtering `Mappings`.   - a `docs` listing of (services, url) * `how` is a pointer to some `contents` (a checkout of a Git repository   with go-templates/markdown/css).
         Multiple `DevPortal`s can exist in the cluster, and the Dev Portal server will show them at different endpoints. A `DevPortal` resource with a special name, `ambassador`, will be used for configuring the default Dev Portal (served at `/docs/` by default).
        EOT
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "DevPortalSpec defines the desired state of DevPortal"
            "properties" = {
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "content" = {
                "description" = "Content specifies where the content shown in the DevPortal come from"
                "properties" = {
                  "branch" = {
                    "type" = "string"
                  }
                  "dir" = {
                    "type" = "string"
                  }
                  "url" = {
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "default" = {
                "description" = "Default must be true when this is the default DevPortal"
                "type" = "boolean"
              }
              "docs" = {
                "description" = "Docs is a static docs definition"
                "items" = {
                  "description" = "DevPortalDocsSpec is a static documentation definition: instead of using a Selector for finding documentation for services, users can provide a static list of <service>:<URL> tuples. These services will be shown in the Dev Portal with the documentation obtained from this URL."
                  "properties" = {
                    "service" = {
                      "description" = "Service is the service being documented"
                      "type" = "string"
                    }
                    "url" = {
                      "description" = "URL is the URL used for obtaining docs"
                      "type" = "string"
                    }
                  }
                  "type" = "object"
                }
                "type" = "array"
              }
              "naming_scheme" = {
                "description" = "Describes how to display \"services\" in the DevPortal. Default namespace.name"
                "enum" = [
                  "namespace.name",
                  "name.prefix",
                ]
                "type" = "string"
              }
              "search" = {
                "description" = "DevPortalSearchSpec allows configuration over search functionality for the DevPortal"
                "properties" = {
                  "enabled" = {
                    "type" = "boolean"
                  }
                  "type" = {
                    "description" = "Type of search. \"title-only\" does a fuzzy search over openapi and page titles \"all-content\" will fuzzy search over all openapi and page content. \"title-only\" is the default. warning:  using all-content may incur a larger memory footprint"
                    "enum" = [
                      "title-only",
                      "all-content",
                    ]
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "selector" = {
                "description" = "Selector is used for choosing what is shown in the DevPortal"
                "properties" = {
                  "matchLabels" = {
                    "additionalProperties" = {
                      "type" = "string"
                    }
                    "description" = "MatchLabels specifies the list of labels that must be present in Mappings for being present in this DevPortal."
                    "type" = "object"
                  }
                  "matchNamespaces" = {
                    "description" = "MatchNamespaces is a list of namespaces that will be included in this DevPortal."
                    "items" = {
                      "type" = "string"
                    }
                    "type" = "array"
                  }
                }
                "type" = "object"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
    ]
  }
}

}

resource "kubernetes_manifest" "hosts_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "hosts.getambassador.io"
  }
  "spec" = {
    "additionalPrinterColumns" = [
      {
        "JSONPath" = ".spec.hostname"
        "name" = "Hostname"
        "type" = "string"
      },
      {
        "JSONPath" = ".status.state"
        "name" = "State"
        "type" = "string"
      },
      {
        "JSONPath" = ".status.phaseCompleted"
        "name" = "Phase Completed"
        "type" = "string"
      },
      {
        "JSONPath" = ".status.phasePending"
        "name" = "Phase Pending"
        "type" = "string"
      },
      {
        "JSONPath" = ".metadata.creationTimestamp"
        "name" = "Age"
        "type" = "date"
      },
    ]
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "Host"
      "listKind" = "HostList"
      "plural" = "hosts"
      "singular" = "host"
    }
    "scope" = "Namespaced"
    "subresources" = {
      "status" = {}
    }
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "Host is the Schema for the hosts API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "HostSpec defines the desired state of Host"
            "properties" = {
              "acmeProvider" = {
                "description" = "Specifies whether/who to talk ACME with to automatically manage the $tlsSecret."
                "properties" = {
                  "authority" = {
                    "description" = "Specifies who to talk ACME with to get certs. Defaults to Let's Encrypt; if \"none\" (case-insensitive), do not try to do ACME for this Host."
                    "type" = "string"
                  }
                  "email" = {
                    "type" = "string"
                  }
                  "privateKeySecret" = {
                    "description" = <<-EOT
                    Specifies the Kubernetes Secret to use to store the private key of the ACME account (essentially, where to store the auto-generated password for the auto-created ACME account).  You should not normally need to set this--the default value is based on a combination of the ACME authority being registered wit and the email address associated with the account.
                     Note that this is a native-Kubernetes-style core.v1.LocalObjectReference, not an Ambassador-style `{name}.{namespace}` string.  Because we're opinionated, it does not support referencing a Secret in another namespace (because most native Kubernetes resources don't support that), but if we ever abandon that opinion and decide to support non-local references it, it would be by adding a `namespace:` field by changing it from a core.v1.LocalObjectReference to a core.v1.SecretReference, not by adopting the `{name}.{namespace}` notation.
                    EOT
                    "properties" = {
                      "name" = {
                        "description" = "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names TODO: Add other useful fields. apiVersion, kind, uid?"
                        "type" = "string"
                      }
                    }
                    "type" = "object"
                  }
                  "registration" = {
                    "description" = "This is normally set automatically"
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "ambassadorId" = {
                "description" = "A compatibility alias for \"ambassador_id\"; because Host used to be specified with protobuf, and jsonpb allowed either \"ambassador_id\" or \"ambassadorId\", and even though we didn't tell people about \"ambassadorId\" it's what the web policy console generated because of jsonpb.  So Hosts with 'ambassadorId' exist in the wild."
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "ambassador_id" = {
                "description" = "Common to all Ambassador objects (and optional)."
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "hostname" = {
                "description" = "Hostname by which the Ambassador can be reached."
                "type" = "string"
              }
              "previewUrl" = {
                "description" = "Configuration for the Preview URL feature of Service Preview. Defaults to preview URLs not enabled."
                "properties" = {
                  "enabled" = {
                    "description" = "Is the Preview URL feature enabled?"
                    "type" = "boolean"
                  }
                  "type" = {
                    "description" = "What type of Preview URL is allowed?"
                    "enum" = [
                      "Path",
                    ]
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "requestPolicy" = {
                "description" = "Request policy definition."
                "properties" = {
                  "insecure" = {
                    "properties" = {
                      "action" = {
                        "enum" = [
                          "Redirect",
                          "Reject",
                          "Route",
                        ]
                        "type" = "string"
                      }
                      "additionalPort" = {
                        "type" = "integer"
                      }
                    }
                    "type" = "object"
                  }
                }
                "type" = "object"
              }
              "selector" = {
                "description" = "Selector by which we can find further configuration. Defaults to hostname=$hostname"
                "properties" = {
                  "matchExpressions" = {
                    "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                    "items" = {
                      "description" = "A label selector requirement is a selector that contains values, a key, and an operator that relates the key and values."
                      "properties" = {
                        "key" = {
                          "description" = "key is the label key that the selector applies to."
                          "type" = "string"
                        }
                        "operator" = {
                          "description" = "operator represents a key's relationship to a set of values. Valid operators are In, NotIn, Exists and DoesNotExist."
                          "type" = "string"
                        }
                        "values" = {
                          "description" = "values is an array of string values. If the operator is In or NotIn, the values array must be non-empty. If the operator is Exists or DoesNotExist, the values array must be empty. This array is replaced during a strategic merge patch."
                          "items" = {
                            "type" = "string"
                          }
                          "type" = "array"
                        }
                      }
                      "required" = [
                        "key",
                        "operator",
                      ]
                      "type" = "object"
                    }
                    "type" = "array"
                  }
                  "matchLabels" = {
                    "additionalProperties" = {
                      "type" = "string"
                    }
                    "description" = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is \"key\", the operator is \"In\", and the values array contains only \"value\". The requirements are ANDed."
                    "type" = "object"
                  }
                }
                "type" = "object"
              }
              "tls" = {
                "description" = "TLS configuration.  It is not valid to specify both `tlsContext` and `tls`."
                "properties" = {
                  "alpn_protocols" = {
                    "type" = "string"
                  }
                  "ca_secret" = {
                    "type" = "string"
                  }
                  "cacert_chain_file" = {
                    "type" = "string"
                  }
                  "cert_chain_file" = {
                    "type" = "string"
                  }
                  "cert_required" = {
                    "type" = "boolean"
                  }
                  "cipher_suites" = {
                    "items" = {
                      "type" = "string"
                    }
                    "type" = "array"
                  }
                  "ecdh_curves" = {
                    "items" = {
                      "type" = "string"
                    }
                    "type" = "array"
                  }
                  "max_tls_version" = {
                    "type" = "string"
                  }
                  "min_tls_version" = {
                    "type" = "string"
                  }
                  "private_key_file" = {
                    "type" = "string"
                  }
                  "redirect_cleartext_from" = {
                    "type" = "integer"
                  }
                  "sni" = {
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "tlsContext" = {
                "description" = <<-EOT
                Name of the TLSContext the Host resource is linked with. It is not valid to specify both `tlsContext` and `tls`.
                 Note that this is a native-Kubernetes-style core.v1.LocalObjectReference, not an Ambassador-style `{name}.{namespace}` string.  Because we're opinionated, it does not support referencing a Secret in another namespace (because most native Kubernetes resources don't support that), but if we ever abandon that opinion and decide to support non-local references it, it would be by adding a `namespace:` field by changing it from a core.v1.LocalObjectReference to a core.v1.SecretReference, not by adopting the `{name}.{namespace}` notation.
                EOT
                "properties" = {
                  "name" = {
                    "description" = "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names TODO: Add other useful fields. apiVersion, kind, uid?"
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "tlsSecret" = {
                "description" = <<-EOT
                Name of the Kubernetes secret into which to save generated certificates.  If ACME is enabled (see $acmeProvider), then the default is $hostname; otherwise the default is "".  If the value is "", then we do not do TLS for this Host.
                 Note that this is a native-Kubernetes-style core.v1.LocalObjectReference, not an Ambassador-style `{name}.{namespace}` string.  Because we're opinionated, it does not support referencing a Secret in another namespace (because most native Kubernetes resources don't support that), but if we ever abandon that opinion and decide to support non-local references it, it would be by adding a `namespace:` field by changing it from a core.v1.LocalObjectReference to a core.v1.SecretReference, not by adopting the `{name}.{namespace}` notation.
                EOT
                "properties" = {
                  "name" = {
                    "description" = "Name of the referent. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names TODO: Add other useful fields. apiVersion, kind, uid?"
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
            }
            "type" = "object"
          }
          "status" = {
            "description" = "HostStatus defines the observed state of Host"
            "properties" = {
              "errorBackoff" = {
                "type" = "string"
              }
              "errorReason" = {
                "description" = "errorReason, errorTimestamp, and errorBackoff are valid when state==Error."
                "type" = "string"
              }
              "errorTimestamp" = {
                "format" = "date-time"
                "type" = "string"
              }
              "phaseCompleted" = {
                "description" = "phaseCompleted and phasePending are valid when state==Pending or state==Error."
                "enum" = [
                  "NA",
                  "DefaultsFilled",
                  "ACMEUserPrivateKeyCreated",
                  "ACMEUserRegistered",
                  "ACMECertificateChallenge",
                ]
                "type" = "string"
              }
              "phasePending" = {
                "description" = "phaseCompleted and phasePending are valid when state==Pending or state==Error."
                "enum" = [
                  "NA",
                  "DefaultsFilled",
                  "ACMEUserPrivateKeyCreated",
                  "ACMEUserRegistered",
                  "ACMECertificateChallenge",
                ]
                "type" = "string"
              }
              "state" = {
                "description" = "The first value listed in the Enum marker becomes the \"zero\" value, and it would be great if \"Pending\" could be the default value; but it's Important that the \"zero\" value be able to be shown as empty/omitted from display, and we really do want `kubectl get hosts` to say \"Pending\" in the \"STATE\" column, and not leave the column empty."
                "enum" = [
                  "Initial",
                  "Pending",
                  "Ready",
                  "Error",
                ]
                "type" = "string"
              }
              "tlsCertificateSource" = {
                "enum" = [
                  "Unknown",
                  "None",
                  "Other",
                  "ACME",
                ]
                "type" = "string"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
    ]
  }
}

}

resource "kubernetes_manifest" "kubernetesendpointresolvers_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "kubernetesendpointresolvers.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "KubernetesEndpointResolver"
      "listKind" = "KubernetesEndpointResolverList"
      "plural" = "kubernetesendpointresolvers"
      "singular" = "kubernetesendpointresolver"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "KubernetesEndpointResolver is the Schema for the kubernetesendpointresolver API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "KubernetesEndpointResolver tells Ambassador to use Kubernetes Endpoints resources to resolve services. It actually has no spec other than the AmbassadorID."
            "properties" = {
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "kubernetesserviceresolvers_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "kubernetesserviceresolvers.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "KubernetesServiceResolver"
      "listKind" = "KubernetesServiceResolverList"
      "plural" = "kubernetesserviceresolvers"
      "singular" = "kubernetesserviceresolver"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "KubernetesServiceResolver is the Schema for the kubernetesserviceresolver API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "KubernetesServiceResolver tells Ambassador to use Kubernetes Service resources to resolve services. It actually has no spec other than the AmbassadorID."
            "properties" = {
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "logservices_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "logservices.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "LogService"
      "listKind" = "LogServiceList"
      "plural" = "logservices"
      "singular" = "logservice"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "LogService is the Schema for the logservices API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "LogServiceSpec defines the desired state of LogService"
            "properties" = {
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "driver" = {
                "enum" = [
                  "tcp",
                  "http",
                ]
                "type" = "string"
              }
              "driver_config" = {
                "properties" = {
                  "additional_log_headers" = {
                    "items" = {
                      "properties" = {
                        "during_request" = {
                          "type" = "boolean"
                        }
                        "during_response" = {
                          "type" = "boolean"
                        }
                        "during_trailer" = {
                          "type" = "boolean"
                        }
                        "header_name" = {
                          "type" = "string"
                        }
                      }
                      "type" = "object"
                    }
                    "type" = "array"
                  }
                }
                "type" = "object"
              }
              "flush_interval_byte_size" = {
                "type" = "integer"
              }
              "flush_interval_time" = {
                "type" = "integer"
              }
              "grpc" = {
                "type" = "boolean"
              }
              "service" = {
                "type" = "string"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "mappings_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "mappings.getambassador.io"
  }
  "spec" = {
    "additionalPrinterColumns" = [
      {
        "JSONPath" = ".spec.host"
        "name" = "Source Host"
        "type" = "string"
      },
      {
        "JSONPath" = ".spec.prefix"
        "name" = "Source Prefix"
        "type" = "string"
      },
      {
        "JSONPath" = ".spec.service"
        "name" = "Dest Service"
        "type" = "string"
      },
      {
        "JSONPath" = ".status.state"
        "name" = "State"
        "type" = "string"
      },
      {
        "JSONPath" = ".status.reason"
        "name" = "Reason"
        "type" = "string"
      },
    ]
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "Mapping"
      "listKind" = "MappingList"
      "plural" = "mappings"
      "singular" = "mapping"
    }
    "scope" = "Namespaced"
    "subresources" = {
      "status" = {}
    }
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "Mapping is the Schema for the mappings API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "MappingSpec defines the desired state of Mapping"
            "properties" = {
              "add_linkerd_headers" = {
                "type" = "boolean"
              }
              "add_request_headers" = {
                "additionalProperties" = {
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                    {
                      "type" = "object"
                    },
                  ]
                }
                "type" = "object"
              }
              "add_response_headers" = {
                "additionalProperties" = {
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                    {
                      "type" = "object"
                    },
                  ]
                }
                "type" = "object"
              }
              "allow_upgrade" = {
                "description" = <<-EOT
                A case-insensitive list of the non-HTTP protocols to allow "upgrading" to from HTTP via the "Connection: upgrade" mechanism[1].  After the upgrade, Ambassador does not interpret the traffic, and behaves similarly to how it does for TCPMappings.
                 [1]: https://tools.ietf.org/html/rfc7230#section-6.7
                 For example, if your upstream service supports WebSockets, you would write
                    allow_upgrade:    - websocket
                 Or if your upstream service supports upgrading from HTTP to SPDY (as the Kubernetes apiserver does for `kubectl exec` functionality), you would write
                    allow_upgrade:    - spdy/3.1
                EOT
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "auth_context_extensions" = {
                "additionalProperties" = {
                  "type" = "string"
                }
                "type" = "object"
              }
              "auto_host_rewrite" = {
                "type" = "boolean"
              }
              "bypass_auth" = {
                "type" = "boolean"
              }
              "bypass_error_response_overrides" = {
                "description" = "If true, bypasses any `error_response_overrides` set on the Ambassador module."
                "type" = "boolean"
              }
              "case_sensitive" = {
                "type" = "boolean"
              }
              "circuit_breakers" = {
                "items" = {
                  "properties" = {
                    "max_connections" = {
                      "type" = "integer"
                    }
                    "max_pending_requests" = {
                      "type" = "integer"
                    }
                    "max_requests" = {
                      "type" = "integer"
                    }
                    "max_retries" = {
                      "type" = "integer"
                    }
                    "priority" = {
                      "enum" = [
                        "default",
                        "high",
                      ]
                      "type" = "string"
                    }
                  }
                  "type" = "object"
                }
                "type" = "array"
              }
              "cluster_idle_timeout_ms" = {
                "type" = "integer"
              }
              "cluster_max_connection_lifetime_ms" = {
                "type" = "integer"
              }
              "cluster_tag" = {
                "type" = "string"
              }
              "connect_timeout_ms" = {
                "type" = "integer"
              }
              "cors" = {
                "properties" = {
                  "credentials" = {
                    "type" = "boolean"
                  }
                  "exposed_headers" = {
                    "description" = "StringOrStringList is just what it says on the tin, but note that it will always marshal as a list of strings right now."
                    "items" = {
                      "type" = "string"
                    }
                    "oneOf" = [
                      {
                        "type" = "string"
                      },
                      {
                        "type" = "array"
                      },
                    ]
                  }
                  "headers" = {
                    "description" = "StringOrStringList is just what it says on the tin, but note that it will always marshal as a list of strings right now."
                    "items" = {
                      "type" = "string"
                    }
                    "oneOf" = [
                      {
                        "type" = "string"
                      },
                      {
                        "type" = "array"
                      },
                    ]
                  }
                  "max_age" = {
                    "type" = "string"
                  }
                  "methods" = {
                    "description" = "StringOrStringList is just what it says on the tin, but note that it will always marshal as a list of strings right now."
                    "items" = {
                      "type" = "string"
                    }
                    "oneOf" = [
                      {
                        "type" = "string"
                      },
                      {
                        "type" = "array"
                      },
                    ]
                  }
                  "origins" = {
                    "description" = "StringOrStringList is just what it says on the tin, but note that it will always marshal as a list of strings right now."
                    "items" = {
                      "type" = "string"
                    }
                    "oneOf" = [
                      {
                        "type" = "string"
                      },
                      {
                        "type" = "array"
                      },
                    ]
                  }
                }
                "type" = "object"
              }
              "docs" = {
                "description" = "DocsInfo provides some extra information about the docs for the Mapping (used by the Dev Portal)"
                "properties" = {
                  "display_name" = {
                    "type" = "string"
                  }
                  "ignored" = {
                    "type" = "boolean"
                  }
                  "path" = {
                    "type" = "string"
                  }
                  "url" = {
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "enable_ipv4" = {
                "type" = "boolean"
              }
              "enable_ipv6" = {
                "type" = "boolean"
              }
              "envoy_override" = {
                "description" = "UntypedDict is relatively opaque as a Go type, but it preserves its contents in a roundtrippable way."
                "type" = "object"
              }
              "error_response_overrides" = {
                "description" = "Error response overrides for this Mapping. Replaces all of the `error_response_overrides` set on the Ambassador module, if any."
                "items" = {
                  "description" = "A response rewrite for an HTTP error response"
                  "properties" = {
                    "body" = {
                      "description" = "The new response body"
                      "properties" = {
                        "content_type" = {
                          "description" = "The content type to set on the error response body when using text_format or text_format_source. Defaults to 'text/plain'."
                          "type" = "string"
                        }
                        "json_format" = {
                          "additionalProperties" = {
                            "type" = "string"
                          }
                          "description" = "A JSON response with content-type: application/json. The values can contain format text like in text_format."
                          "type" = "object"
                        }
                        "text_format" = {
                          "description" = "A format string representing a text response body. Content-Type can be set using the `content_type` field below."
                          "type" = "string"
                        }
                        "text_format_source" = {
                          "description" = "A format string sourced from a file on the Ambassador container. Useful for larger response bodies that should not be placed inline in configuration."
                          "properties" = {
                            "filename" = {
                              "description" = "The name of a file on the Ambassador pod that contains a format text string."
                              "type" = "string"
                            }
                          }
                          "type" = "object"
                        }
                      }
                      "type" = "object"
                    }
                    "on_status_code" = {
                      "description" = "The status code to match on -- not a pointer because it's required."
                      "maximum" = 599
                      "minimum" = 400
                      "type" = "integer"
                    }
                  }
                  "required" = [
                    "body",
                    "on_status_code",
                  ]
                  "type" = "object"
                }
                "minItems" = 1
                "type" = "array"
              }
              "grpc" = {
                "type" = "boolean"
              }
              "headers" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "type" = "object"
              }
              "host" = {
                "type" = "string"
              }
              "host_redirect" = {
                "type" = "boolean"
              }
              "host_regex" = {
                "type" = "boolean"
              }
              "host_rewrite" = {
                "type" = "string"
              }
              "idle_timeout_ms" = {
                "type" = "integer"
              }
              "keepalive" = {
                "properties" = {
                  "idle_time" = {
                    "type" = "integer"
                  }
                  "interval" = {
                    "type" = "integer"
                  }
                  "probes" = {
                    "type" = "integer"
                  }
                }
                "type" = "object"
              }
              "labels" = {
                "additionalProperties" = {
                  "description" = "A MappingLabelGroupsArray is an array of MappingLabelGroups. I know, complex."
                  "items" = {
                    "additionalProperties" = {
                      "description" = "A MappingLabelsArray is the value in the MappingLabelGroup: an array of label specifiers."
                      "items" = {
                        "description" = "A MappingLabelSpecifier (finally!) defines a single label. There are multiple kinds of label, so this is more complex than we'd like it to be. See the remarks about schema on custom types in `./common.go`."
                      }
                      "type" = "array"
                    }
                    "description" = "A MappingLabelGroup is a single element of a MappingLabelGroupsArray: a second map, where the key is a human-readable name that identifies the group."
                    "type" = "object"
                  }
                  "type" = "array"
                }
                "description" = "A DomainMap is the overall Mapping.spec.Labels type. It maps domains (kind of like namespaces for Mapping labels) to arrays of label groups."
                "type" = "object"
              }
              "load_balancer" = {
                "properties" = {
                  "cookie" = {
                    "properties" = {
                      "name" = {
                        "type" = "string"
                      }
                      "path" = {
                        "type" = "string"
                      }
                      "ttl" = {
                        "type" = "string"
                      }
                    }
                    "required" = [
                      "name",
                    ]
                    "type" = "object"
                  }
                  "header" = {
                    "type" = "string"
                  }
                  "policy" = {
                    "enum" = [
                      "round_robin",
                      "ring_hash",
                      "maglev",
                      "least_request",
                    ]
                    "type" = "string"
                  }
                  "source_ip" = {
                    "type" = "boolean"
                  }
                }
                "required" = [
                  "policy",
                ]
                "type" = "object"
              }
              "method" = {
                "type" = "string"
              }
              "method_regex" = {
                "type" = "boolean"
              }
              "modules" = {
                "items" = {
                  "description" = "UntypedDict is relatively opaque as a Go type, but it preserves its contents in a roundtrippable way."
                  "type" = "object"
                }
                "type" = "array"
              }
              "outlier_detection" = {
                "type" = "string"
              }
              "path_redirect" = {
                "description" = "Path replacement to use when generating an HTTP redirect. Used with `host_redirect`."
                "type" = "string"
              }
              "precedence" = {
                "type" = "integer"
              }
              "prefix" = {
                "type" = "string"
              }
              "prefix_exact" = {
                "type" = "boolean"
              }
              "prefix_redirect" = {
                "description" = "Prefix rewrite to use when generating an HTTP redirect. Used with `host_redirect`."
                "type" = "string"
              }
              "prefix_regex" = {
                "type" = "boolean"
              }
              "priority" = {
                "type" = "string"
              }
              "query_parameters" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "type" = "object"
              }
              "redirect_response_code" = {
                "description" = "The response code to use when generating an HTTP redirect. Defaults to 301. Used with `host_redirect`."
                "enum" = [
                  301,
                  302,
                  303,
                  307,
                  308,
                ]
                "type" = "integer"
              }
              "regex_headers" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "type" = "object"
              }
              "regex_query_parameters" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "type" = "object"
              }
              "regex_redirect" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "description" = "Prefix regex rewrite to use when generating an HTTP redirect. Used with `host_redirect`."
                "type" = "object"
              }
              "regex_rewrite" = {
                "additionalProperties" = {
                  "description" = "BoolOrString is a type that can hold a Boolean or a string."
                  "oneOf" = [
                    {
                      "type" = "string"
                    },
                    {
                      "type" = "boolean"
                    },
                  ]
                }
                "type" = "object"
              }
              "remove_request_headers" = {
                "description" = "StringOrStringList is just what it says on the tin, but note that it will always marshal as a list of strings right now."
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "remove_response_headers" = {
                "description" = "StringOrStringList is just what it says on the tin, but note that it will always marshal as a list of strings right now."
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "resolver" = {
                "type" = "string"
              }
              "retry_policy" = {
                "properties" = {
                  "num_retries" = {
                    "type" = "integer"
                  }
                  "per_try_timeout" = {
                    "type" = "string"
                  }
                  "retry_on" = {
                    "enum" = [
                      "5xx",
                      "gateway-error",
                      "connect-failure",
                      "retriable-4xx",
                      "refused-stream",
                      "retriable-status-codes",
                    ]
                    "type" = "string"
                  }
                }
                "type" = "object"
              }
              "rewrite" = {
                "type" = "string"
              }
              "service" = {
                "type" = "string"
              }
              "shadow" = {
                "type" = "boolean"
              }
              "timeout_ms" = {
                "description" = "The timeout for requests that use this Mapping. Overrides `cluster_request_timeout_ms` set on the Ambassador Module, if it exists."
                "type" = "integer"
              }
              "tls" = {
                "description" = "BoolOrString is a type that can hold a Boolean or a string."
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "boolean"
                  },
                ]
              }
              "use_websocket" = {
                "description" = "use_websocket is deprecated, and is equivlaent to setting `allow_upgrade: [\"websocket\"]`"
                "type" = "boolean"
              }
              "weight" = {
                "type" = "integer"
              }
            }
            "required" = [
              "prefix",
              "service",
            ]
            "type" = "object"
          }
          "status" = {
            "description" = "MappingStatus defines the observed state of Mapping"
            "properties" = {
              "reason" = {
                "type" = "string"
              }
              "state" = {
                "enum" = [
                  "",
                  "Inactive",
                  "Running",
                ]
                "type" = "string"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "modules_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "modules.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "Module"
      "listKind" = "ModuleList"
      "plural" = "modules"
      "singular" = "module"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = <<-EOT
        A Module defines system-wide configuration.  The type of module is controlled by the .metadata.name; valid names are "ambassador" or "tls".
         https://www.getambassador.io/docs/edge-stack/latest/topics/running/ambassador/#the-ambassador-module https://www.getambassador.io/docs/edge-stack/latest/topics/running/tls/#tls-module-deprecated
        EOT
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "properties" = {
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "config" = {
                "description" = "UntypedDict is relatively opaque as a Go type, but it preserves its contents in a roundtrippable way."
                "type" = "object"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "ratelimitservices_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "ratelimitservices.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "RateLimitService"
      "listKind" = "RateLimitServiceList"
      "plural" = "ratelimitservices"
      "singular" = "ratelimitservice"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "RateLimitService is the Schema for the ratelimitservices API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "RateLimitServiceSpec defines the desired state of RateLimitService"
            "properties" = {
              "ambassador_id" = {
                "description" = "Common to all Ambassador objects."
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "domain" = {
                "type" = "string"
              }
              "protocol_version" = {
                "enum" = [
                  "v2",
                  "v3",
                ]
                "type" = "string"
              }
              "service" = {
                "type" = "string"
              }
              "timeout_ms" = {
                "type" = "integer"
              }
              "tls" = {
                "description" = "BoolOrString is a type that can hold a Boolean or a string."
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "boolean"
                  },
                ]
              }
            }
            "required" = [
              "service",
            ]
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "tcpmappings_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "tcpmappings.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "TCPMapping"
      "listKind" = "TCPMappingList"
      "plural" = "tcpmappings"
      "singular" = "tcpmapping"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "TCPMapping is the Schema for the tcpmappings API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "TCPMappingSpec defines the desired state of TCPMapping"
            "properties" = {
              "address" = {
                "type" = "string"
              }
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "circuit_breakers" = {
                "items" = {
                  "properties" = {
                    "max_connections" = {
                      "type" = "integer"
                    }
                    "max_pending_requests" = {
                      "type" = "integer"
                    }
                    "max_requests" = {
                      "type" = "integer"
                    }
                    "max_retries" = {
                      "type" = "integer"
                    }
                    "priority" = {
                      "enum" = [
                        "default",
                        "high",
                      ]
                      "type" = "string"
                    }
                  }
                  "type" = "object"
                }
                "type" = "array"
              }
              "cluster_tag" = {
                "type" = "string"
              }
              "enable_ipv4" = {
                "type" = "boolean"
              }
              "enable_ipv6" = {
                "type" = "boolean"
              }
              "host" = {
                "type" = "string"
              }
              "idle_timeout_ms" = {
                "description" = "FIXME(lukeshu): Surely this should be an 'int'?"
                "type" = "string"
              }
              "port" = {
                "description" = "Port isn't a pointer because it's required."
                "type" = "integer"
              }
              "resolver" = {
                "type" = "string"
              }
              "service" = {
                "type" = "string"
              }
              "tls" = {
                "description" = "BoolOrString is a type that can hold a Boolean or a string."
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "boolean"
                  },
                ]
              }
              "weight" = {
                "type" = "integer"
              }
            }
            "required" = [
              "port",
              "service",
            ]
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "tlscontexts_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "tlscontexts.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "TLSContext"
      "listKind" = "TLSContextList"
      "plural" = "tlscontexts"
      "singular" = "tlscontext"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "TLSContext is the Schema for the tlscontexts API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "TLSContextSpec defines the desired state of TLSContext"
            "properties" = {
              "alpn_protocols" = {
                "type" = "string"
              }
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "ca_secret" = {
                "type" = "string"
              }
              "cacert_chain_file" = {
                "type" = "string"
              }
              "cert_chain_file" = {
                "type" = "string"
              }
              "cert_required" = {
                "type" = "boolean"
              }
              "cipher_suites" = {
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
              "ecdh_curves" = {
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
              "hosts" = {
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
              "max_tls_version" = {
                "enum" = [
                  "v1.0",
                  "v1.1",
                  "v1.2",
                  "v1.3",
                ]
                "type" = "string"
              }
              "min_tls_version" = {
                "enum" = [
                  "v1.0",
                  "v1.1",
                  "v1.2",
                  "v1.3",
                ]
                "type" = "string"
              }
              "private_key_file" = {
                "type" = "string"
              }
              "redirect_cleartext_from" = {
                "type" = "integer"
              }
              "secret" = {
                "type" = "string"
              }
              "secret_namespacing" = {
                "type" = "boolean"
              }
              "sni" = {
                "type" = "string"
              }
            }
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "tracingservices_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "annotations" = {
      "controller-gen.kubebuilder.io/version" = "v0.4.1"
    }
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "tracingservices.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "TracingService"
      "listKind" = "TracingServiceList"
      "plural" = "tracingservices"
      "singular" = "tracingservice"
    }
    "scope" = "Namespaced"
    "validation" = {
      "openAPIV3Schema" = {
        "description" = "TracingService is the Schema for the tracingservices API"
        "properties" = {
          "apiVersion" = {
            "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources"
            "type" = "string"
          }
          "kind" = {
            "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
            "type" = "string"
          }
          "metadata" = {
            "type" = "object"
          }
          "spec" = {
            "description" = "TracingServiceSpec defines the desired state of TracingService"
            "properties" = {
              "ambassador_id" = {
                "description" = <<-EOT
                AmbassadorID declares which Ambassador instances should pay attention to this resource.  May either be a string or a list of strings.  If no value is provided, the default is:
                    ambassador_id:    - "default"
                EOT
                "items" = {
                  "type" = "string"
                }
                "oneOf" = [
                  {
                    "type" = "string"
                  },
                  {
                    "type" = "array"
                  },
                ]
              }
              "config" = {
                "properties" = {
                  "access_token_file" = {
                    "type" = "string"
                  }
                  "collector_cluster" = {
                    "type" = "string"
                  }
                  "collector_endpoint" = {
                    "type" = "string"
                  }
                  "collector_endpoint_version" = {
                    "enum" = [
                      "HTTP_JSON_V1",
                      "HTTP_JSON",
                      "HTTP_PROTO",
                    ]
                    "type" = "string"
                  }
                  "collector_hostname" = {
                    "type" = "string"
                  }
                  "service_name" = {
                    "type" = "string"
                  }
                  "shared_span_context" = {
                    "type" = "boolean"
                  }
                  "trace_id_128bit" = {
                    "type" = "boolean"
                  }
                }
                "type" = "object"
              }
              "driver" = {
                "enum" = [
                  "lightstep",
                  "zipkin",
                  "datadog",
                ]
                "type" = "string"
              }
              "sampling" = {
                "properties" = {
                  "client" = {
                    "type" = "integer"
                  }
                  "overall" = {
                    "type" = "integer"
                  }
                  "random" = {
                    "type" = "integer"
                  }
                }
                "type" = "object"
              }
              "service" = {
                "type" = "string"
              }
              "tag_headers" = {
                "items" = {
                  "type" = "string"
                }
                "type" = "array"
              }
            }
            "required" = [
              "driver",
              "service",
            ]
            "type" = "object"
          }
        }
        "type" = "object"
      }
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "filterpolicies_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "filterpolicies.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "FilterPolicy"
      "plural" = "filterpolicies"
      "shortNames" = [
        "fp",
      ]
      "singular" = "filterpolicy"
    }
    "scope" = "Namespaced"
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1beta2"
        "served" = true
        "storage" = false
      },
      {
        "name" = "v1beta1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}

resource "kubernetes_manifest" "filters_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "filters.getambassador.io"
  }
  "spec" = {
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "Filter"
      "plural" = "filters"
      "shortNames" = [
        "fil",
      ]
      "singular" = "filter"
    }
    "scope" = "Namespaced"
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
      {
        "name" = "v1beta2"
        "served" = true
        "storage" = false
      },
      {
        "name" = "v1beta1"
        "served" = true
        "storage" = false
      },
    ]
  }
}

}


resource "kubernetes_manifest" "projects_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "projects.getambassador.io"
  }
  "spec" = {
    "additionalPrinterColumns" = [
      {
        "JSONPath" = ".spec.prefix"
        "name" = "Prefix"
        "type" = "string"
      },
      {
        "JSONPath" = ".spec.githubRepo"
        "name" = "Repo"
        "type" = "string"
      },
      {
        "JSONPath" = ".metadata.creationTimestamp"
        "name" = "Age"
        "type" = "date"
      },
    ]
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "Project"
      "plural" = "projects"
      "singular" = "project"
    }
    "scope" = "Namespaced"
    "subresources" = {
      "status" = {}
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
    ]
  }
}

}

resource "kubernetes_manifest" "projectrevisions_crd"{
  manifest = {
  "apiVersion" = "apiextensions.k8s.io/v1beta1"
  "kind" = "CustomResourceDefinition"
  "metadata" = {
    "labels" = {
      "app.kubernetes.io/name" = "ambassador"
      "product" = "aes"
    }
    "name" = "projectrevisions.getambassador.io"
  }
  "spec" = {
    "additionalPrinterColumns" = [
      {
        "JSONPath" = ".spec.project.name"
        "name" = "Project"
        "type" = "string"
      },
      {
        "JSONPath" = ".spec.ref"
        "name" = "Ref"
        "type" = "string"
      },
      {
        "JSONPath" = ".spec.rev"
        "name" = "Rev"
        "type" = "string"
      },
      {
        "JSONPath" = ".status.phase"
        "name" = "Status"
        "type" = "string"
      },
      {
        "JSONPath" = ".metadata.creationTimestamp"
        "name" = "Age"
        "type" = "date"
      },
    ]
    "group" = "getambassador.io"
    "names" = {
      "categories" = [
        "ambassador-crds",
      ]
      "kind" = "ProjectRevision"
      "plural" = "projectrevisions"
      "singular" = "projectrevision"
    }
    "scope" = "Namespaced"
    "subresources" = {
      "status" = {}
    }
    "version" = null
    "versions" = [
      {
        "name" = "v2"
        "served" = true
        "storage" = true
      },
    ]
  }
}

}


########### END Ambassador CRDs ####################
