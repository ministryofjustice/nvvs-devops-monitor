#! /bin/bash
# A bash script to deploy:
# - AWS Load Balancer Controller Service account
# - AWS Load Balancer Controller
# - External DNS
# - Nginx Ingress Controller

ORANGE='\033[1;33m'
PURPLE='\033[1;31m'
NC='\033[0m' # No Color

set_variables() {
  printf "\n${ORANGE}############# ${PURPLE}Setting up local variables ${ORANGE}#############${NC}\n"
  namespace=`terraform output -raw terraform_workspace`
  region=`terraform output aws_region`
  aws_assume_role=`terraform output assume_role`
  terraform_outputs_eks_cluster=`terraform output -json eks_cluster`
  eks_cluster_name=`echo $terraform_outputs_eks_cluster | jq -r '.name'`
  eks_cluster_endpoint=`echo $terraform_outputs_eks_cluster | jq -r '.endpoint'`
  lb_controller_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.aws_load_balancer_controller_iam_role_arn'`
  external_dns_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.external_dns_iam_role_arn'`
  terraform_outputs_certificate=`terraform output -json certificate`
  certificate_domain=`echo $terraform_outputs_certificate | jq -r '.certificate_domain'`
  certificate_arn=`echo $terraform_outputs_certificate | jq -r '.certificate_arn'`
  tags=`terraform output -json tags`
}

set_kubeconfig() {
  printf "\n${ORANGE}############# ${PURPLE}Setting up kubeconfig ${ORANGE}#############${NC}\n"
  # Set a user entry in kubeconfig
  kubectl config set-credentials $eks_cluster_name --exec-api-version=client.authentication.k8s.io/v1beta1 --exec-command=aws \
    --exec-arg=eks \
    --exec-arg=get-token \
    --exec-arg=--region \
    --exec-arg=$region \
    --exec-arg=--cluster-name \
    --exec-arg=$eks_cluster_name \
    --exec-arg=--role \
    --exec-arg=$aws_assume_role \
    --exec-env=AWS_PROFILE=$AWS_PROFILE

  # Set a cluster entry in kubeconfig and use the crt file in it
  kubectl config set-cluster $eks_cluster_name --server=$eks_cluster_endpoint --embed-certs --certificate-authority=./kubernetes.ca.crt

  # Set a context entry in kubeconfig
  kubectl config set-context $eks_cluster_name --cluster=$eks_cluster_name --user=$eks_cluster_name --namespace=$namespace

  # Set the current-context in a kubeconfig file
  kubectl config use-context $eks_cluster_name
}

deploy_service_accounts_helm_chart() {
  printf "\n${ORANGE}############# ${PURPLE}Creating all the service accounts ${ORANGE}#############${NC}\n"
  helm upgrade --install service-accounts ./service-accounts \
    -n kube-system \
    --set eks_cluster.lb_controller_iam_role_arn=$lb_controller_iam_role_arn
}

annotate_service_account() {
  printf "\n${ORANGE}############# ${PURPLE}Adding annotation in aws-load-balancer-controller service account ${ORANGE}#############${NC}\n"
  kubectl annotate serviceaccount --overwrite -n kube-system aws-load-balancer-controller \
    eks.amazonaws.com/sts-regional-endpoints=true
}

deploy_aws_lb_controller() {
  printf "\n${ORANGE}############# ${PURPLE}Deploying AWS load balancer controller ${ORANGE}#############${NC}\n"
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
  printf "\n${ORANGE}############# ${PURPLE}Deploying External-DNS pod ${ORANGE}#############${NC}\n"
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
  helm repo update
  helm upgrade --install external-dns external-dns/external-dns \
    -n external-dns \
    --create-namespace \
    --set serviceAccount.name=external-dns \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$external_dns_iam_role_arn \
    --set txtOwnerId=ti-dev-poc-ingress-nginx \
    --set txtPrefix=ti-poc-ext-dns \
    --set domainFilters[0]=$certificate_domain
}

deploy_ingress_nginx() {
  printf "\n${ORANGE}############# ${PURPLE}Deploying Nginx ingress controller ${ORANGE}#############${NC}\n"
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
  set_kubeconfig
  deploy_service_accounts_helm_chart
  annotate_service_account
  deploy_aws_lb_controller
  deploy_external_dns
  deploy_ingress_nginx
}

if `terraform output eks_enabled`; then
  printf "\n${ORANGE}############# ${PURPLE}Preparing the EKS Cluster for deployments ${ORANGE}#############${NC}\n"
  main
else
  printf "\n${ORANGE}############# ${PURPLE}Nothing to deploy as EKS is not enabled ${ORANGE}#############${NC}\n"
fi
