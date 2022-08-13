variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "private_subnets_cidr_blocks" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "create" {
  type = bool
}
