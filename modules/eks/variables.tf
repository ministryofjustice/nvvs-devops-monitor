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

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "enabled" {
  description = "Feature flag that controls the deployment of the infrastructure in a given environment"
  type        = bool
  default     = true
}
