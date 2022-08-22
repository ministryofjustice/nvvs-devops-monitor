output "application_name" {
  value = var.application_name
}

output "terraform_workspace" {
  value = terraform.workspace
}
output "aws_region" {
  value = var.aws_region
}
output "assume_role" {
  value     = var.assume_role
  sensitive = true
}

output "eks_enabled" {
  value = var.create_eks
}

output "vpc" {
  value = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets_cidr_blocks
    public_subnets  = module.vpc.public_subnets_cidr_blocks
  }
  sensitive = true
}

output "certificate" {
  value = {
    certificate_domain = module.acm.distinct_domain_names[0]
    certificate_arn    = module.acm.acm_certificate_arn
  }
  sensitive = true
}

output "eks_cluster" {
  value = {
    issuer                                    = module.eks.issuer
    name                                      = module.eks.cluster_name
    endpoint                                  = module.eks.endpoint
    aws_load_balancer_controller_iam_role_arn = module.eks.aws_load_balancer_controller_iam_role_arn
    external_dns_iam_role_arn                 = module.eks.external_dns_iam_role_arn
    aws_efs_csi_driver_iam_role_arn           = module.eks.aws_efs_csi_driver_iam_role_arn
    efs_file_system_id                        = module.eks.efs_file_system_id
    thanos_iam_role_arn                       = module.eks.thanos_iam_role_arn
    thanos_storage_s3_bucket_name             = module.eks.thanos_storage_s3_bucket_name
  }
  sensitive = true
}

output "kubeconfig_certificate_authority_data" {
  value     = base64decode(module.eks.kubeconfig_certificate_authority_data)
  sensitive = true
}

output "tags" {
  value = join("\\,", [for key, value in module.label.tags : "${key}=${value}"])
}
