variable "infra_bucket" {
  type = map(any)
  default = {
    dev   = "project-terraform-state-dev"
    stage = "project-terraform-state-stage"
    prod  = "project-terraform-state-prod"
  }
}

variable "infra_file" {
  type = map(any)
  default = {
    dev   = "dev/project-eks-bootstrap.tfstate"
    stage = "stage/project-eks-bootstrap.tfstate"
    prod  = "prod/project-eks-bootstrap.tfstate"
  }
}

variable "env" {
  default = "dev"
}

variable "region" {
  default = "us-east-1"
}
