output "vpc" {
  value = {
    vpc_id          = module.vpc.vpc_id
    private_subnets = module.vpc.private_subnets_cidr_blocks
    public_subnets  = module.vpc.public_subnets_cidr_blocks
  }
}

output "certificate" {
  value = {
    certificate_domain = module.acm.distinct_domain_names
    certificate_arn    = module.acm.acm_certificate_arn
  }
}

output "eks_cluster" {
  value = var.create_eks ? {
    issuer                                    = module.eks.issuer
    name                                      = module.eks.cluster_name
    endpoint                                  = module.eks.endpoint
    aws_load_balancer_controller_iam_role_arn = module.eks.aws_load_balancer_controller_iam_role_arn
    external_dns_iam_role_arn                 = module.eks.external_dns_iam_role_arn
  } : null
}

output "kubeconfig_certificate_authority_data" {
  value = var.create_eks ? module.eks.kubeconfig_certificate_authority_data : null
}

output "tags" {
  value = join("\\,", [for key, value in module.label.tags : "${key}=${value}"])
}
