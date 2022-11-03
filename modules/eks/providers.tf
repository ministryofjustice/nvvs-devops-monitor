terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.development,
        aws.pre_production
      ]
    }
  }
}
