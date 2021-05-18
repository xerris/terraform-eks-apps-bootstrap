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

data "terraform_remote_state" "project_eks_infra" {
  backend = "s3"
  config = {
    bucket       = var.bucket
    key          = var.key
    region       = var.region
    #role_arn     = "arn:aws:iam::${var.account_id}:role/aldo-jenkins"
    #session_name = "${var.env}-omni-dataapps"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.project_eks_infra.outputs.project_eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.project_eks_infra.outputs.project_eks_cluster_id
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "flux" {}

provider "kubectl" {}

data "flux_install" "main" {
  target_path    = var.target_path
  network_policy = false
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }
}

# Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "apply" {
  content = data.flux_install.main.content
}
locals {
  apply = [ for v in data.kubectl_file_documents.apply.documents : {
      data: yamldecode(v)
      content: v
    }
  ]
}

output "kubectl_apply" {
  value = { content = data.kubectl_file_documents.apply
  }

}

# Apply manifests on the cluster
resource "kubectl_manifest" "apply" {
  for_each   = { for v in local.apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body = each.value
}

####################################################
####################################################
####################################################

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "https://github.com/${var.github_owner}/${var.repository_name}"
  branch      = var.branch
}

# Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  sync = [ for v in data.kubectl_file_documents.sync.documents : {
      data: yamldecode(v)
      content: v
    }
  ]
}

# Apply manifests on the cluster

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body = each.value
}

output "kubectl_sync" {
  value = { content = data.kubectl_file_documents.sync
  }

}
# Generate a Kubernetes secret with the Git credentials
resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.apply]
  metadata {
    name      = "flux-system" #data.flux_sync.main.name
    namespace = "flux-system"
  }

  data = {
    username = "sizingpoker-bot"
    password = var.flux_token
  }
}