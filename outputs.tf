output "application_name" {
  value = var.application_name
}

output "terraform_workspace" {
  value = terraform.workspace
}

output "enabled" {
  value = var.enabled
}
output "aws_region" {
  value = var.aws_region
}
output "assume_role" {
  value     = var.assume_role
  sensitive = true
}

output "vpc" {
  value = var.enabled ? {
    vpc_id          = module.vpc[0].vpc_id
    private_subnets = module.vpc[0].private_subnets_cidr_blocks
    public_subnets  = module.vpc[0].public_subnets_cidr_blocks
  } : null
  sensitive = true
}

output "certificate" {
  value = var.enabled ? {
    certificate_domain = module.acm[0].distinct_domain_names[0]
    certificate_arn    = module.acm[0].acm_certificate_arn
  } : null
  sensitive = true
}

output "eks_cluster" {
  value = var.enabled ? {
    issuer                                    = module.eks[0].issuer
    name                                      = module.eks[0].cluster_name
    endpoint                                  = module.eks[0].endpoint
    aws_load_balancer_controller_iam_role_arn = module.eks[0].aws_load_balancer_controller_iam_role_arn
    external_dns_iam_role_arn                 = module.eks[0].external_dns_iam_role_arn
    aws_efs_csi_driver_iam_role_arn           = module.eks[0].aws_efs_csi_driver_iam_role_arn
    aws_secrets_store_csi_driver_iam_role_arn = module.eks[0].aws_secrets_store_csi_driver_iam_role_arn
    efs_file_system_id                        = module.eks[0].efs_file_system_id
    thanos_iam_role_arn                       = module.eks[0].thanos_iam_role_arn
    thanos_storage_s3_bucket_name             = module.eks[0].thanos_storage_s3_bucket_name
    cloudwatch_exporter_iam_role_arn          = module.eks[0].cloudwatch_exporter_iam_role_arn
    db_endpoint                               = module.eks[0].db_endpoint
  } : null
  sensitive = true
}

output "kubeconfig_certificate_authority_data" {
  value     = var.enabled ? base64decode(module.eks[0].kubeconfig_certificate_authority_data) : null
  sensitive = true
}

output "tags" {
  value = join("\\,", [for key, value in module.label.tags : "${key}=${value}"])
}
