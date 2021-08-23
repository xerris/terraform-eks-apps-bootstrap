#!/bin/bash
set -o nounset
set -o errexit


echo "###############################"
echo "## Starting Terraform script ##"
echo "###############################"

ENV="${ENV:-dev}"
AWS_REGION="${AWS_REGION:-ca-central-1}"
echo "Configuring AWS Profiles"
export AWS_PROFILE=default

aws configure set role_arn "arn:aws:iam::${ACCOUNT_ID}:role/deployment-role" --profile deployment-profile
aws configure set source_profile default --profile deployment-profile
aws configure set role_session_name test-session --profile deployment-profile
export AWS_PROFILE=deployment-profile

APPLY=${1:-0} #If set terraform will force apply changes
commit_hash=`git rev-parse --short HEAD`
build_number="${BITBUCKET_BUILD_NUMBER:=local}"
#export TF_LOG=DEBUG
export TF_VAR_commit_hash="${commit_hash}"
export TF_VAR_build_number="${build_number}"
aws eks update-kubeconfig --region $AWS_REGION --name project_eks_cluster-$ENV --kubeconfig "~/.kube/config"
terraform init \
-backend-config="bucket=project-eks-terraform-state-${ENV}" \
-backend-config="key=${ENV}/project-eks-apps-bootstrap.tfstate" \
-backend-config="dynamodb_table=${ENV}-project-eks-terraform-state-lock-dynamo" \
-backend-config="region=${AWS_REGION}"
#-backend-config="role_arn=arn:aws:iam::${ACCOUNT_ID}:role/aldo-jenkins" \
#-backend-config="session_name=${ENV}-omni-dataapps"

terraform validate
export GITHUB_TOKEN=$2
export GITHUB_OWNER=xerris
#terraform plan -var-file=envs/${ENV}.tfvars -var="flux_token=${2}"

if [ $APPLY == 2 ]; then
    echo "###############################"
    echo "## Executing terraform destroy ##"
    echo "###############################"
    terraform destroy --auto-approve -var-file=envs/${ENV}.tfvars -var="flux_token=${2}"
fi


if [ $APPLY == 1 ]; then
    echo "###############################"
    echo "## Executing terraform apply ##"
    echo "###############################"
    terraform apply --auto-approve -var-file=envs/${ENV}.tfvars -var="flux_token=${2}" -target=module.ambassador_crd_install
    sleep 10
    terraform apply --auto-approve -var-file=envs/${ENV}.tfvars -var="flux_token=${2}"
fi
