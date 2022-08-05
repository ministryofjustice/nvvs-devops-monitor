output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "aws_load_balancer_controller_iam_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}

output "external_dns_iam_role_arn" {
  value = aws_iam_role.external_dns.arn
}

output "issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
