terraform {
  backend "s3" {}
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "0.0.13"
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

provider "aws" {
  region  = var.region
  #assume_role {
  #  role_arn     = "arn:aws:iam::${var.account_id}:role/aldo-jenkins"
  #  session_name = "${var.env}-omni-dataapps"
  #}
}

data "terraform_remote_state" "project_eks_infra" {
  backend = "s3"
  config = {
    bucket       = var.infra_bucket[var.env]
    key          = var.infra_file[var.env]
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
}
