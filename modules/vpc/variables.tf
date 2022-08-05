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

variable "tags" {
  type = map(string)
}
