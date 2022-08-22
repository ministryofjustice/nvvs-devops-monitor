resource "aws_efs_file_system" "this" {
  creation_token = "${var.prefix}-efs"

  tags = var.tags

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

# Create a security group with an inbound rule that allows inbound NFS traffic for the Amazon EFS mount points.
resource "aws_security_group" "allow_inbound_nfs_traffic" {
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

resource "aws_efs_mount_target" "private_subnet_1" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnets[0]
  security_groups = [aws_security_group.allow_inbound_nfs_traffic.id]
}

resource "aws_efs_mount_target" "private_subnet_2" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnets[1]
  security_groups = [aws_security_group.allow_inbound_nfs_traffic.id]
}

resource "aws_efs_mount_target" "private_subnet_3" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnets[2]
  security_groups = [aws_security_group.allow_inbound_nfs_traffic.id]
}
