resource "aws_db_instance" "this" {
  count                       = var.enabled ? 1 : 0
  identifier                  = "${var.prefix}-grafana-db"
  allocated_storage           = 20
  storage_type                = "gp3"
  engine                      = "postgres"
  apply_immediately           = true
  engine_version              = "14.13"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  instance_class              = "db.t3.micro"
  db_name                     = "grafanadb"
  username                    = var.db_username
  password                    = var.db_password
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.admin_db.id]
  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  deletion_protection         = terraform.workspace == "production" ? true : false

  tags = var.tags
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = var.tags
}

resource "aws_security_group" "admin_db" {
  name        = "${var.prefix}-database"
  description = "Allow connections to the DB"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group_rule" "admin_db_in_from_eks" {
  description       = "Allow access to admin database from app containers"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.admin_db.id
  cidr_blocks       = var.private_subnets_cidr_blocks
}
