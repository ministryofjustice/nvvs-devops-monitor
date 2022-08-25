variable "application_name" {
  description = "An URL friendly name of the application. This name would form the application url together with the route53 zone domain name."
  type        = string
  default     = "mojo-infrastructure-monitoring"
}

variable "enabled" {
  description = "Feature flag that controls the deployment of the infrastructure in a given environment"
  type        = bool
  default     = false
}

variable "assume_role" {
  description = "The role to assume in different environments"
  type        = string
}

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
