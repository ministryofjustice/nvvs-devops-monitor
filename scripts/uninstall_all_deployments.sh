#!/bin/bash
# A bash script to uninstall all kubernetes deployments

ORANGE='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

uninstall_grafana() {
  helm uninstall grafana -n grafana
  helm repo remove grafana
  kubectl delete namespace grafana
}

uninstall_ingress_nginx() {
  kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
  helm uninstall ingress-nginx -n ingress-nginx
  helm repo remove ingress-nginx
  kubectl delete namespace ingress-nginx
}

uninstall_external_dns() {
  helm uninstall external-dns -n external-dns
  helm repo remove external-dns
  kubectl delete namespace external-dns
}

uninstall_aws_lb_controller() {
  helm uninstall aws-load-balancer-controller -n kube-system
  helm repo remove eks
}

uninstall_service_accounts_helm_chart() {
  helm uninstall service-accounts -n kube-system
}

uninstall_kube-prometheus-stack() {
  helm uninstall kube-prometheus-stack -n monitoring
  helm repo remove prometheus-community
  kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
  kubectl delete crd alertmanagers.monitoring.coreos.com
  kubectl delete crd podmonitors.monitoring.coreos.com
  kubectl delete crd probes.monitoring.coreos.com
  kubectl delete crd prometheuses.monitoring.coreos.com
  kubectl delete crd prometheusrules.monitoring.coreos.com
  kubectl delete crd servicemonitors.monitoring.coreos.com
  kubectl delete crd thanosrulers.monitoring.coreos.com
  kubectl delete namespace monitoring
}

main() {
  uninstall_grafana
  uninstall_ingress_nginx
  uninstall_external_dns
  uninstall_aws_lb_controller
  uninstall_service_accounts_helm_chart
  uninstall_kube-prometheus-stack
}

if `terraform output eks_enabled`; then
  printf "\n${ORANGE}############# ${PURPLE}Uninstalling shared helm charts from the EKS Cluster ${ORANGE}#############${NC}\n"
  main
else
  printf "\n${ORANGE}############# ${PURPLE}Nothing to uninstall as EKS is not enabled ${ORANGE}#############${NC}\n"
fi
