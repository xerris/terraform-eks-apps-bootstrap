env = "dev"
region = "us-east-1"
target_path = "apps/helm"
github_owner = "xerris"
repository_name = "terraform-eks-apps-bootstrap"
branch= "dev"
repo_provider =  "github"
default_components = ["source-controller", "kustomize-controller", "notification-controller"]
components = []