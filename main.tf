terraform {
  backend "s3" {
    bucket         = "staff-ci-infrastructure-client-monitoring-cluster-tf-state"
    dynamodb_table = "staff-ci-infrastructure-client-monitoring-cluster-tf-lock-table"
    region         = "eu-west-2"
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "main"

  assume_role {
    role_arn = var.assume_role
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "development"

  assume_role {
    role_arn = var.assume_role_development
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "pre_production"

  assume_role {
    role_arn = var.assume_role_pre_production
  }
}

data "aws_availability_zones" "available_zones" {
  count = local.always_create
  state = "available"
}

locals {
  ## work around to prevent destruction of exisisting resources in production
  ## avoids risk of importing into state file of live services.
  always_create = 1
}

module "label" {
  source           = "./modules/label"
  name             = "nvvs-devops-monitor"
  application_name = var.application_name
}

module "vpc_label" {
  source           = "./modules/label"
  name             = "nvvs-devops-monitor"
  application_name = var.application_name
}

module "vpc" {
  count                          = local.always_create
  source                         = "./modules/vpc"
  prefix                         = module.vpc_label.id
  cidr                           = "10.180.100.0/22"
  region                         = var.aws_region
  available_zones                = var.enabled ? data.aws_availability_zones.available_zones[0].zone_ids : ["eu-west-2a"] // If environment off lower VPC avilability
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_id             = var.transit_gateway_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  byoip_pool_id                  = var.byoip_pool_id
  corsham_mgmt_range             = var.corsham_mgmt_range
  farnborough_mgmt_range         = var.farnborough_mgmt_range
  network_services_cidr_block    = var.network_services_cidr_block
  tags                           = module.vpc_label.tags

  providers = {
    aws = aws.main
  }
}

module "eks_label" {
  source           = "./modules/label"
  name             = "nvvs-devops-monitor-eks"
  application_name = var.application_name
}

module "eks" {
  count                       = local.always_create
  source                      = "./modules/eks"
  prefix                      = module.eks_label.id
  vpc_id                      = module.vpc[0].vpc_id
  private_subnets             = module.vpc[0].private_subnets
  private_subnets_cidr_blocks = module.vpc[0].private_subnets_cidr_blocks
  db_username                 = var.db_username
  db_password                 = var.db_password
  enabled                     = var.enabled

  tags = module.eks_label.tags

  providers = {
    aws                = aws.main
    aws.development    = aws.development
    aws.pre_production = aws.pre_production
  }
}
