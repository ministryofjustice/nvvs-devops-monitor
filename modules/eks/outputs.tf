output "cluster_name" {
  value = var.create ? aws_eks_cluster.this[0].name : null
}

output "endpoint" {
  value = var.create ? aws_eks_cluster.this[0].endpoint : null
}

output "kubeconfig_certificate_authority_data" {
  value = var.create ? aws_eks_cluster.this[0].certificate_authority[0].data : null
}

output "aws_load_balancer_controller_iam_role_arn" {
  value = var.create ? aws_iam_role.aws_load_balancer_controller[0].arn : null
}

output "external_dns_iam_role_arn" {
  value = var.create ? aws_iam_role.external_dns[0].arn : null
}

output "issuer" {
  value = var.create ? aws_eks_cluster.this[0].identity[0].oidc[0].issuer : null
}
