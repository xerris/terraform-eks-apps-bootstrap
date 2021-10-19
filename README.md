# Terraform-eks-apps-bootstrap
## Introduction
This bootstrap installs a Terraform server and creates a VPC, EKS cluster, IAM roles and an RDS database along with an optional bastion host and Cloudwatch alarm.

## Environment Variables

The credentials requested belogs to the user `project-deploy-user`  created at the master  account `XXXXXXXXXXX` with permissions to assume a deployment role called `project-deploy-role` accross the other accounts.

| Name | Value | Description |
|------|---------|--------|
|AWS_ACCESS_KEY_ID| n/a | n/a |
|AWS_SECRET_ACCESS_KEY| n/a | n/a |
|AWS_REGION | ca-central-1| n/a |



## Requirements


| Name | Version |
|------|---------|
| Terraform | 1.0 |
| awscli | aws-cli/1.19.76 |
| jq | jq-1.6 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_flux"></a> [flux](#module\_flux) | ./apps/fluxcd | n/a |
| <a name="module_prometheus-operator"></a> [prometheus-operator](#module\_prometheus-operator) | ./apps/prometheus-operator | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_branch"></a> [branch](#input\_branch) | n/a | `string` | `"main"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | `"dev"` | no |
| <a name="input_flux_token"></a> [flux\_token](#input\_flux\_token) | n/a | `any` | n/a | yes |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | n/a | `string` | `"xerris"` | no |
| <a name="input_infra_bucket"></a> [infra\_bucket](#input\_infra\_bucket) | n/a | `map(any)` | <pre>{<br>  "dev": "project-terraform-state-dev",<br>  "prod": "project-terraform-state-prod",<br>  "stage": "project-terraform-state-stage"<br>}</pre> | no |
| <a name="input_infra_file"></a> [infra\_file](#input\_infra\_file) | n/a | `map(any)` | <pre>{<br>  "dev": "dev/project-eks-bootstrap.tfstate",<br>  "prod": "prod/project-eks-bootstrap.tfstate",<br>  "stage": "stage/project-eks-bootstrap.tfstate"<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | n/a | `string` | `"terraform-eks-apps-bootstrap"` | no |
| <a name="input_target_path"></a> [target\_path](#input\_target\_path) | n/a | `string` | `"apps"` | no |

## Outputs

## Execution Steps

* Initialize the Environment Variables

```
export AWS_ACCESS_KEY_ID="XXXXXXXXXXXXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="YYYYYYYYYYYYYYYYYYYYYYYYY"
export AWS_REGION=ca-central-1

```

The `terraform_exec.sh` script receives one parameter that indicates the action to be executed.

```
0 = Executes a terraform plan
1 = Executes a terraform apply
2 = Executes a terraform destroy
```


* Execute a Terraform Plan on the project folder

```
terraform_exec.sh 0
```

* Execute a Terraform apply on the project folder

```
terraform_exec.sh 1
```

* Execute a Terraform Destroy on the project folder

```
terraform_exec.sh 2
```