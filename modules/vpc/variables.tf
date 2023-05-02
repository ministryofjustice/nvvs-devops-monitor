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

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is `true`"
  type        = bool
  default     = true
}
variable "manage_default_network_acl" {
  description = "Should be true to adopt and manage Default Network ACL"
  type        = bool
  default     = false
}
variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = bool
  default     = false
}
variable "manage_default_route_table" {
  description = "Should be true to manage default route table"
  type        = bool
  default     = false
}