module "acm_label" {
  source           = "./modules/label"
  name             = "mojo-ima-acm"
  application_name = var.application_name
}

module "acm" {
  count   = var.enabled ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.1"

  domain_name = var.domain_name
  zone_id     = var.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "${var.application_name}.${var.domain_name}",
    "*.${var.application_name}.${var.domain_name}"
  ]

  wait_for_validation = true

  tags = module.acm_label.tags

  providers = {
    aws = aws.main
  }
}
