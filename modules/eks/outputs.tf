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

output "aws_efs_csi_driver_iam_role_arn" {
  value = aws_iam_role.aws_efs_csi_driver.arn
}

output "aws_ebs_csi_driver_iam_role_arn" {
  value = aws_iam_role.aws_ebs_csi_driver.arn
}

output "efs_file_system_id" {
  value = aws_efs_file_system.this.id
}

output "thanos_iam_role_arn" {
  value = aws_iam_role.thanos.arn
}

output "issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "thanos_storage_s3_bucket_name" {
  value = aws_s3_bucket.thanos_storage.id
}

output "cloudwatch_exporter_iam_role_arn" {
  value = aws_iam_role.cloudwatch_exporter.arn
}

output "cloudwatch_exporter_development_iam_role_arn" {
  value = aws_iam_role.cloudwatch_exporter_development != [] ? aws_iam_role.cloudwatch_exporter_development[0].arn : ""
}

output "cloudwatch_exporter_pre_production_iam_role_arn" {
  value = aws_iam_role.cloudwatch_exporter_pre_production != [] ? aws_iam_role.cloudwatch_exporter_pre_production[0].arn : ""
}

output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}
