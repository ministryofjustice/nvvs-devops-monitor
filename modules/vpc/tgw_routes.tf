# Route Corsham mgmt traffic through the TGW
resource "aws_route" "corsham_mgmt" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = module.vpc.public_route_table_ids[0]
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.corsham_mgmt_range
}

# Route Farnborough mgmt traffic through the TGW
resource "aws_route" "farnborough_mgmt" {
  count                  = var.enable_transit_gateway ? 1 : 0
  route_table_id         = module.vpc.public_route_table_ids[0]
  gateway_id             = var.transit_gateway_id
  destination_cidr_block = var.farnborough_mgmt_range
}

# # Route network services VPC through the TGW
# resource "aws_route" "network_services" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = var.network_services_cidr_block
# }

# # Route MoJO DNS VPC traffic through the TGW
# resource "aws_route" "mojo_dns_1" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.mojo_dns_ip_1}/32"
# }

# resource "aws_route" "mojo_dns_2" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.mojo_dns_ip_2}/32"
# }

# # Route Blackbox DNS probes through the TGW
# resource "aws_route" "dom1_dns_1" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.dom1_dns_range_1}/24"
# }

# resource "aws_route" "dom1_dns_2" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.dom1_dns_range_2}/24"
# }

# resource "aws_route" "quantum_dns_1" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.quantum_dns_range_1}/24"
# }

# resource "aws_route" "quantum_dns_2" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.quantum_dns_range_2}/24"
# }

# resource "aws_route" "quantum_dns_3" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.quantum_dns_ip_1}/32"
# }

# resource "aws_route" "quantum_dns_4" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = "${var.quantum_dns_ip_2}/32"
# }

# # Route PSN traffic through the TGW
# resource "aws_route" "psn_route_1" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = var.psn_team_protected_range_1
# }

# # Route PSN VPC traffic through the TGW
# resource "aws_route" "psn_route_2" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = var.psn_team_protected_range_2
# }

# # Route SOP OCI traffic through the TGW
# resource "aws_route" "sop_oci" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = var.sop_oci_range
# }

# # Route Corsham 5260 traffic through the TGW
# resource "aws_route" "corsham_5260" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = var.corsham_5260_ip
# }

# # Route Farnham 5260 traffic through the TGW
# resource "aws_route" "farnborough_5260" {
#   count                  = var.enable_transit_gateway ? 1 : 0
#   route_table_id         = module.vpc.default_route_table_id
#   gateway_id             = var.transit_gateway_id
#   destination_cidr_block = var.farnborough_5260_ip
# }
