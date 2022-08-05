#!/bin/bash
# A bash script to uninstall all kubernetes deployments

uninstall_ingress_nginx() {
  kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
  helm uninstall ingress-nginx -n ingress-nginx
  helm repo remove ingress-nginx
  kubectl delete namespace ingress-nginx
}

uninstall_external_dns() {
  helm uninstall external-dns
  helm repo remove external-dns
}

uninstall_aws_lb_controller() {
  helm uninstall aws-load-balancer-controller -n kube-system
  helm repo remove eks
}

uninstall_service_accounts_helm_chart() {
  helm uninstall service-accounts -n kube-system
}

main() {
  uninstall_ingress_nginx
  uninstall_external_dns
  uninstall_aws_lb_controller
  uninstall_service_accounts_helm_chart
}

main
