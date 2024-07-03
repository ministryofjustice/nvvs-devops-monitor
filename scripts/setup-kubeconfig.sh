#!/bin/bash

set -e

# Function to print messages with colors
print_message() {
    ORANGE='\033[0;33m'
    PURPLE='\033[0;35m'
    NC='\033[0m' # No Color
    printf "\n${ORANGE}############# ${PURPLE}$1 ${ORANGE}#############${NC}\n"
}

# Function to set local variables from terraform outputs
set_variables() {
    print_message "Setting up local variables from terraform outputs and AWS parameter store"

    # Set local variables from terraform outputs
    terraform_outputs=$(terraform output -json)
    application_name=$(echo "$terraform_outputs" | jq -r '.application_name.value')
    namespace=$(echo "$terraform_outputs" | jq -r '.terraform_workspace.value')
    region=$(echo "$terraform_outputs" | jq -r '.aws_region.value')
    aws_assume_role=$(echo "$terraform_outputs" | jq -r '.assume_role.value')
    terraform_outputs_eks_cluster=$(echo "$terraform_outputs" | jq -r '.eks_cluster.value')
    eks_cluster_name=$(echo "$terraform_outputs_eks_cluster" | jq -r '.name')
    eks_cluster_endpoint=$(echo "$terraform_outputs_eks_cluster" | jq -r '.endpoint')
    kubeconfig_certificate_authority_data=$(echo "$terraform_outputs" | jq -r '.kubeconfig_certificate_authority_data.value')
}

# Function to configure kubeconfig
set_kubeconfig() {
    print_message "Setting up kubeconfig"

    kubectl config set-credentials "$eks_cluster_name" --exec-api-version=client.authentication.k8s.io/v1beta1 --exec-command=aws \
        --exec-arg=eks \
        --exec-arg=get-token \
        --exec-arg=--region \
        --exec-arg="$region" \
        --exec-arg=--cluster-name \
        --exec-arg="$eks_cluster_name" \
        --exec-arg=--role \
        --exec-arg="$aws_assume_role" \
        $(if [ -n "$AWS_PROFILE" ]; then echo "--exec-env=AWS_PROFILE=$AWS_PROFILE"; fi)

    echo "$kubeconfig_certificate_authority_data" > temp_kubernetes_ca.crt
    kubectl config set-cluster "$eks_cluster_name" --server="$eks_cluster_endpoint" --embed-certs=true --certificate-authority=./temp_kubernetes_ca.crt
    rm ./temp_kubernetes_ca.crt

    kubectl config set-context "$eks_cluster_name" --cluster="$eks_cluster_name" --user="$eks_cluster_name" --namespace="$namespace"
    kubectl config use-context "$eks_cluster_name"
}

# Main script execution
set_variables
set_kubeconfig

echo "Kubeconfig setup complete for cluster: $eks_cluster_name"
print_message "Kubeconfig setup is complete"
