module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = var.prefix
  cidr = var.cidr
  azs  = var.available_zones

  enable_dns_hostnames          = true
  enable_dns_support            = true
  enable_nat_gateway            = true
  map_public_ip_on_launch       = var.map_public_ip_on_launch
  manage_default_network_acl    = var.manage_default_network_acl
  manage_default_security_group = var.manage_default_security_group
  manage_default_route_table    = var.manage_default_route_table
  reuse_nat_ips                 = terraform.workspace == "development" || terraform.workspace == "pre-production" ? false : true
  external_nat_ip_ids           = terraform.workspace == "development" || terraform.workspace == "pre-production" ? [] : aws_eip.gw.*.id
  // Lower costs, by lowering availability
  single_nat_gateway = terraform.workspace == "development" || terraform.workspace == "pre-production" ? true : false

  private_subnets = [for cidr_block in cidrsubnets(var.cidr, 2, 2, 2) : cidrsubnets(cidr_block, 1, 1)[0]]
  private_subnet_tags = merge(
    { for k, v in var.tags : k => v if k != "Name" },
    {
      "kubernetes.io/role/internal-elb" = "1"
    },
  )

  public_subnets = [for cidr_block in cidrsubnets(var.cidr, 2, 2, 2) : cidrsubnets(cidr_block, 1, 1)[1]]
  public_subnet_tags = merge(
    { for k, v in var.tags : k => v if k != "Name" },
    {
      "kubernetes.io/role/elb" = "1"
    },
  )

  igw_tags                 = var.tags
  nat_gateway_tags         = { for k, v in var.tags : k => v if k != "Name" }
  private_route_table_tags = { for k, v in var.tags : k => v if k != "Name" }
  public_route_table_tags  = { for k, v in var.tags : k => v if k != "Name" }

}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}

resource "aws_eip" "gw" {
  domain           = "vpc"
  count            = terraform.workspace == "development" ? 0 : length(var.available_zones)
  public_ipv4_pool = var.byoip_pool_id

  tags = var.tags
}
