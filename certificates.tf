module "acm_label" {
  source = "./modules/label"
  name   = "mojo-ima-acm"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.domain_name
  zone_id     = var.zone_id

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  wait_for_validation = true

  tags = module.acm_label.tags

  providers = {
    aws = aws.main
  }
}
