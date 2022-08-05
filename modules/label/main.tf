module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = terraform.workspace
  stage     = terraform.workspace == "production" ? "prod" : "staging"
  name      = var.name
  delimiter = "-"

  label_order = ["name", "stage", "namespace"]

  tags = {
    "business-unit"    = "MoJO-HQ"
    "environment-name" = terraform.workspace
    "is-production"    = terraform.workspace == "production" ? "true" : "false"
    "application"      = "mojo-infrastructure-monitoring"
    "source-code"      = "https://github.com/ministryofjustice/mojo-infrastructure-monitoring"
  }
}
