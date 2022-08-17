#!/bin/bash
# A bash script to uninstall all kubernetes deployments

ORANGE='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

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
  kubectl delete configmap thanos-query-datasource -n monitoring
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
