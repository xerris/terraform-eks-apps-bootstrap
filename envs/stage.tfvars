env = "stage"
region = "us-east-1"
target_path = "/overlays"
github_owner = "xerris"
repository_name = "2048-k8-app"
branch= "main"
repo_provider =  "github"
default_components = ["source-controller", "kustomize-controller", "notification-controller"]
components = ["helm-controller"]