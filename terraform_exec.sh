#!/bin/bash
set -o nounset
set -o errexit


echo "###############################"
echo "## Starting Terraform script ##"
echo "###############################"

ENV="${ENV:-dev}"
AWS_REGION="${AWS_REGION:-us-east-1}"
#echo "Configuring AWS Profiles"
#aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile aldo-user
#aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile aldo-user
#aws configure set role_arn "arn:aws:iam::${ACCOUNT_ID}:role/aldo-jenkins" --profile aldo-role
#aws configure set source_profile aldo-user --profile aldo-role
#aws configure set role_session_name aldo-test-session --profile aldo-role
#export AWS_PROFILE=aldo-role

APPLY=${1:-0} #If set terraform will force apply changes
commit_hash=`git rev-parse --short HEAD`
build_number="${BITBUCKET_BUILD_NUMBER:=local}"
#export TF_LOG=TRACE
export TF_VAR_commit_hash="${commit_hash}"
export TF_VAR_build_number="${build_number}"
pip install --upgrade awscli
aws eks update-kubeconfig --region $AWS_REGION --name project_eks_cluster-$ENV --kubeconfig "~/.kube/config"
terraform init \
-backend-config="bucket=project-terraform-state-${ENV}" \
-backend-config="key=${ENV}/project-eks-apps-bootstrap.tfstate" \
-backend-config="dynamodb_table=${ENV}-project-terraform-state-lock-dynamo" \
-backend-config="region=${AWS_REGION}"
#-backend-config="role_arn=arn:aws:iam::${ACCOUNT_ID}:role/aldo-jenkins" \
#-backend-config="session_name=${ENV}-omni-dataapps"

terraform validate
terraform plan -var-file=envs/${ENV}.tfvars -var="flux_token=${2}"

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
    terraform apply --auto-approve -var-file=envs/${ENV}.tfvars -var="flux_token=${2}"
fi
