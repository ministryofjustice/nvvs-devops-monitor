resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/aws/vpc/${var.prefix}/flow-logs"
  retention_in_days = terraform.workspace == "production" ? 90 : 7
}
