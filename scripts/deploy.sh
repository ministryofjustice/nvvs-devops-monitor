#!/bin/bash
# A bash script to deploy:
# - AWS Load Balancer Controller Service account
# - AWS Load Balancer Controller
# - External DNS
# - Nginx Ingress Controller

set_variables() {
  terraform_outputs_eks_cluster=`terraform output -json eks_cluster`
  eks_cluster_name=`echo $terraform_outputs_eks_cluster | jq -r '.name'`
  eks_cluster_endpoint=`echo $terraform_outputs_eks_cluster | jq -r '.endpoint'`
  lb_controller_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.aws_load_balancer_controller_iam_role_arn'`
  external_dns_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.external_dns_iam_role_arn'`
  eks_cluster_certificate_authority_data=`terraform output -json kubeconfig_certificate_authority_data`
  terraform_outputs_certificate=`terraform output -json certificate`
  certificate_domain=`echo $terraform_outputs_certificate | jq -r '.certificate_domain[0]'`
  certificate_arn=`echo $terraform_outputs_certificate | jq -r '.certificate_arn'`
  tags=`terraform output -json tags`
}

set_kubeconfig() {
  kubectl config set-credentials $eks_cluster_name-admin --exec-api-version=client.authentication.k8s.io/v1beta1 --exec-command=aws \
    --exec-args=eks \
    --exec-args=get-token \
    --exec-args=--region \
    --exec-args=$region \
    --exec-args=--cluster-name \
    --exec-args=$eks_cluster_name

  echo $$eks_cluster_certificate_authority_data >> "certificate.crt"

  kubectl config set-cluster $eks_cluster_name --server=$eks_cluster_endpoint --certificate-authority="certificate.crt"
}

deploy_service_accounts_helm_chart() {
  helm upgrade --install service-accounts ./service-accounts \
    -n kube-system \
    --set eks_cluster.lb_controller_iam_role_arn=$lb_controller_iam_role_arn
}

annotate_service_account() {
  kubectl annotate serviceaccount --overwrite -n kube-system aws-load-balancer-controller \
    eks.amazonaws.com/sts-regional-endpoints=true
}

deploy_aws_lb_controller() {
  kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
  helm repo add eks https://aws.github.io/eks-charts
  helm repo update
  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set image.repository=602401143452.dkr.ecr.eu-west-2.amazonaws.com/amazon/aws-load-balancer-controller \
    --set clusterName=$eks_cluster_name \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller
}

deploy_external_dns() {
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
  helm repo update
  helm upgrade --install external-dns external-dns/external-dns \
    --set serviceAccount.name=external-dns \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$external_dns_iam_role_arn \
    --set txtOwnerId=ti-dev-poc-ingress-nginx \
    --set txtPrefix=ti-poc-ext-dns \
    --set domainFilters[0]=$certificate_domain
}

deploy_ingress_nginx() {
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm upgrade --install -f values.ingress-nginx.yaml --create-namespace ingress-nginx ingress-nginx/ingress-nginx \
    -n ingress-nginx \
    --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"="ti-test-app\."$certificate_domain"\." \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-cert"=$certificate_arn \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-additional-resource-tags"=$tags
}

main() {
  set_variables
  deploy_service_accounts_helm_chart
  annotate_service_account
  deploy_aws_lb_controller
  deploy_external_dns
  deploy_ingress_nginx
}

main
