module "flux"{
    source = "apps/fluxcd"
    target_path = var.target_path
    github_owner = var.github_owner
    repository_name = var.repository_name
    branch = var.branch
    flux_token  = var.flux_token

}
