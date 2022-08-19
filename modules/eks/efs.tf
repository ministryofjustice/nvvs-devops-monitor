resource "aws_efs_file_system" "this" {
  count          = var.create ? 1 : 0
  creation_token = "${var.prefix}-efs"

  tags = var.tags

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

# Create a security group with an inbound rule that allows inbound NFS traffic for the Amazon EFS mount points.
resource "aws_security_group" "allow_inbound_nfs_traffic" {
  count       = var.create ? 1 : 0
  name        = "${var.prefix}-EFSSecurityGroup"
  description = "Allow inbound NFS traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS traffic from private subnets"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.private_subnets_cidr_blocks
  }

  tags = var.tags
}

resource "aws_efs_mount_target" "this" {
  for_each = {
    for subnet in var.private_subnets : subnet => subnet
    if var.create
  }
  # for_each        = var.create ? toset(var.private_subnets) : null
  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = each.key
  security_groups = [aws_security_group.allow_inbound_nfs_traffic[0].id]
}
