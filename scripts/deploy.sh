#! /bin/bash
# A bash script to deploy:
# - AWS Load Balancer Controller Service account
# - AWS Load Balancer Controller
# - External DNS
# - Nginx Ingress Controller

ORANGE='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

set_variables() {
  printf "\n${ORANGE}############# ${PURPLE}Setting up local variables ${ORANGE}#############${NC}\n"
  application_name=`terraform output -raw application_name`
  namespace=`terraform output -raw terraform_workspace`
  region=`terraform output aws_region`
  aws_assume_role=`terraform output assume_role`
  terraform_outputs_eks_cluster=`terraform output -json eks_cluster`
  eks_cluster_name=`echo $terraform_outputs_eks_cluster | jq -r '.name'`
  eks_cluster_endpoint=`echo $terraform_outputs_eks_cluster | jq -r '.endpoint'`
  kubeconfig_certificate_authority_data=`terraform output -raw kubeconfig_certificate_authority_data`
  lb_controller_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.aws_load_balancer_controller_iam_role_arn'`
  external_dns_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.external_dns_iam_role_arn'`
  terraform_outputs_certificate=`terraform output -json certificate`
  certificate_domain=`echo $terraform_outputs_certificate | jq -r '.certificate_domain'`
  certificate_arn=`echo $terraform_outputs_certificate | jq -r '.certificate_arn'`
  application_domain=`echo $application_name"."$certificate_domain`
  tags=`terraform output -raw tags`
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

  # Create a temporary kubernetes certificate authority cert file
  cat > temp_kubernetes_ca.crt << EOL
$kubeconfig_certificate_authority_data
EOL

  # Set a cluster entry in kubeconfig and use the cert file in it
  kubectl config set-cluster $eks_cluster_name --server=$eks_cluster_endpoint --embed-certs=true --certificate-authority=./temp_kubernetes_ca.crt

  # Remove the temporary cert file
  rm ./temp_kubernetes_ca.crt

  # Set a context entry in kubeconfig
  kubectl config set-context $eks_cluster_name --cluster=$eks_cluster_name --user=$eks_cluster_name --namespace=$namespace

  # Set the current-context in a kubeconfig file
  kubectl config use-context $eks_cluster_name
}

deploy_kube-prometheus-stack() {
  printf "\n${ORANGE}############# ${PURPLE}Deploying Kube prometheus stack ${ORANGE}#############${NC}\n"
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    -f ./k8s-values/values.kube-prometheus-stack.yaml \
    -n monitoring \
    --create-namespace
}

deploy_service_accounts_helm_chart() {
  printf "\n${ORANGE}############# ${PURPLE}Creating all the service accounts ${ORANGE}#############${NC}\n"
  helm upgrade --install service-accounts ./k8s-helm-charts/service-accounts \
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
    -f ./k8s-values/values.aws-load-balancer-controller.yaml \
    -n kube-system \
    --set clusterName=$eks_cluster_name
}

deploy_external_dns() {
  printf "\n${ORANGE}############# ${PURPLE}Deploying External-DNS ${ORANGE}#############${NC}\n"
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
  helm repo update
  helm upgrade --install external-dns external-dns/external-dns \
    -f ./k8s-values/values.external-dns.yaml \
    -n external-dns \
    --create-namespace \
    --set txtOwnerId=$application_name \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=$external_dns_iam_role_arn \
    --set domainFilters[0]=$certificate_domain
}

deploy_ingress_nginx() {
  printf "\n${ORANGE}############# ${PURPLE}Deploying Nginx ingress controller ${ORANGE}#############${NC}\n"
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    -f ./k8s-values/values.ingress-nginx.yaml \
    -n ingress-nginx \
    --create-namespace \
    --set controller.service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"=$application_domain \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-cert"=$certificate_arn \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-additional-resource-tags"=$tags
}

deploy_grafana() {
  printf "\n${ORANGE}############# ${PURPLE}Deploying Grafana ${ORANGE}#############${NC}\n"
  helm repo add grafana https://grafana.github.io/helm-charts
  helm repo update
  helm upgrade --install grafana grafana/grafana \
    -f ./k8s-values/values.grafana.yaml \
    -n grafana \
    --create-namespace \
    --set ingress.hosts[0]=$application_domain
}

main() {
  set_variables
  set_kubeconfig
  deploy_kube-prometheus-stack
  deploy_service_accounts_helm_chart
  annotate_service_account
  deploy_aws_lb_controller
  deploy_external_dns
  deploy_ingress_nginx
  deploy_grafana
}

if `terraform output eks_enabled`; then
  printf "\n${ORANGE}############# ${PURPLE}Preparing the EKS Cluster for deployments ${ORANGE}#############${NC}\n"
  main
else
  printf "\n${ORANGE}############# ${PURPLE}Nothing to deploy as EKS is not enabled ${ORANGE}#############${NC}\n"
fi
