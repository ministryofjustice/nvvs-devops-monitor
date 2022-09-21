variable "region" {
  type = string
}

variable "prefix" {
  type = string
}

variable "cidr" {
  type = string
}

variable "available_zones" {
  type = list(string)
}

variable "enable_transit_gateway" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "transit_gateway_route_table_id" {
  type = string
}

# variable "network_services_cidr_block" {
#   type = string
# }

variable "byoip_pool_id" {
  type = string
}

variable "corsham_mgmt_range" {
  type = string
}

variable "farnborough_mgmt_range" {
  type = string
}

variable "network_services_cidr_block" {
  type = string
}

variable "tags" {
  type = map(string)
}
