module "flux2"{
    source = "./apps/flux2"
    target_path = "${var.target_path}/${var.env}"
    repository_name = "terraform-eks-apps-bootstrap"
    repo_url = "https://github.com/${var.github_owner}/${var.repository_name}"
    branch = var.branch
    flux_token  = var.flux_token
    bucket       = var.infra_bucket[var.env]
    key          = var.infra_file[var.env]
    region =  var.region
    repo_provider = var.repo_provider
    components = var.components
    default_components = var.default_components

}

module "prometheus-operator"{
    source = "./apps/prometheus-operator"
}

output "data_github"{
  value = module.flux2.data_github
}