variable "prefix" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "create" {
  type = bool
}
