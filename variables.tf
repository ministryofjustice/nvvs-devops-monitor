variable "aws_region" {
  description = "The AWS region to create things in"
  type        = string
  default     = "eu-west-2"
}

variable "domain_name" {
  description = "The domain to use for the certificate in acm"
  type        = string
}

variable "zone_id" {
  description = "The AWS Route53 zone id for the domain used for the var.domain_name"
  type        = string
}
