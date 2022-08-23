#!/bin/bash
# A bash script to uninstall all kubernetes deployments

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
  lb_controller_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.aws_load_balancer_controller_iam_role_arn'`
  external_dns_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.external_dns_iam_role_arn'`
  efs_csi_driver_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.aws_efs_csi_driver_iam_role_arn'`
  efs_file_system_id=`echo $terraform_outputs_eks_cluster | jq -r '.efs_file_system_id'`
  thanos_iam_role_arn=`echo $terraform_outputs_eks_cluster | jq -r '.thanos_iam_role_arn'`
  thanos_storage_s3_bucket_name=`echo $terraform_outputs_eks_cluster | jq -r '.thanos_storage_s3_bucket_name'`
  kubeconfig_certificate_authority_data=`terraform output -raw kubeconfig_certificate_authority_data`
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
    --exec-arg=$aws_assume_role

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

uninstall_cns_team_monitoring() {
  # Delete manually created configmaps
  kubectl delete configmaps -n monitoring kea-dhcp-metrics-grafana-dashboard
  kubectl delete configmaps -n dhcp-lease-statistics-grafana-dashboard
  # Uninstall the helm chart
  helm uninstall cns-team-monitoring -n monitoring
}

uninstall_grafana() {
  helm uninstall grafana -n grafana
  helm repo remove grafana
  kubectl delete pvc grafana-efs-claim -n grafana
  kubectl delete namespace grafana
}

uninstall_ingress_nginx() {
  # This ValidatingWebhookConfiguration throws errors when ingress controller is removed and redeployed, when it throws error, manually delete it and then redeploy:
  kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
  helm uninstall ingress-nginx -n ingress-nginx
  helm repo remove ingress-nginx
  kubectl delete namespace ingress-nginx
}

uninstall_external_dns() {
  helm uninstall external-dns -n external-dns
  helm repo remove external-dns
  # Clean up the dashboard configmap as it was manually created:
  kubectl delete configmap external-dns -n external-dns
  kubectl delete namespace external-dns
}

uninstall_aws_efs_csi_driver() {
  helm uninstall aws-efs-csi-driver -n kube-system
  helm repo remove aws-efs-csi-driver
}

uninstall_aws_lb_controller() {
  helm uninstall aws-load-balancer-controller -n kube-system
  helm repo remove eks
}

uninstall_shared_resources_helm_chart() {
  helm uninstall shared-resources -n kube-system
}

uninstall_thanos_stack() {
  helm uninstall thanos -n monitoring
  # Clean up the dashboard and datasource configmaps as it was manually created:
  kubectl delete configmap thanos-overview -n monitoring
  kubectl delete configmap thanos-query-grafana-datasource -n monitoring
  helm repo remove bitnami
}

uninstall_kube-prometheus-stack() {
  helm uninstall kube-prometheus-stack -n monitoring
  helm repo remove prometheus-community
  # CRDs created by this chart are not removed by default and should be manually cleaned up:
  kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
  kubectl delete crd alertmanagers.monitoring.coreos.com
  kubectl delete crd podmonitors.monitoring.coreos.com
  kubectl delete crd probes.monitoring.coreos.com
  kubectl delete crd prometheuses.monitoring.coreos.com
  kubectl delete crd prometheusrules.monitoring.coreos.com
  kubectl delete crd servicemonitors.monitoring.coreos.com
  kubectl delete crd thanosrulers.monitoring.coreos.com
  kubectl delete namespace monitoring
  # kubelet service in kube-system created by this chart is not removed by default and should be manually cleaned up:
  kubectl delete service/kube-prometheus-stack-kubelet -n kube-system
}

main() {
  set_variables
  set_kubeconfig
  uninstall_grafana
  uninstall_ingress_nginx
  uninstall_external_dns
  uninstall_aws_efs_csi_driver
  uninstall_aws_lb_controller
  uninstall_shared_resources_helm_chart
  uninstall_thanos_stack
  uninstall_kube-prometheus-stack
}

if `terraform output eks_enabled`; then
  printf "\n${ORANGE}############# ${PURPLE}Uninstalling shared helm charts from the EKS Cluster ${ORANGE}#############${NC}\n"
  main
else
  printf "\n${ORANGE}############# ${PURPLE}Nothing to uninstall as EKS is not enabled ${ORANGE}#############${NC}\n"
fi
