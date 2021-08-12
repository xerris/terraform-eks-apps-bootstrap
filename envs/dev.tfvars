env = "dev"
region = "us-east-1"
target_path = "/overlays"
github_owner = "xerris"
repository_name = "2048-k8-app"
branch= "dev"
repo_provider =  "github"
default_components = ["source-controller", "kustomize-controller", "notification-controller"]
components = ["helm-controller"]
ambassador_service_values = {
    "service1" = {
        service_name  = "ambassador"
        lb_type = "alb"
        internal   = false
    },
    "service2" = {
        service_name  = "ambassador-nlb"
        lb_type = "nlb"
        internal   = false
    }
}
