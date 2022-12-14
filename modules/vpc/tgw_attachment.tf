resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  vpc_id             = module.vpc.vpc_id
  transit_gateway_id = var.transit_gateway_id
  subnet_ids         = module.vpc.private_subnets

  tags = var.tags
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
}
