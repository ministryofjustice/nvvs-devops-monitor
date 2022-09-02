resource "aws_db_instance" "this" {
  identifier                  = "${var.prefix}-grafana-db" 
  allocated_storage           = 10
  storage_type                = "gp2"
  engine                      = "postgres"
  engine_version              = "14.4"
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  instance_class              = "db.t3.micro"
  db_name                     = "grafanadb"
  username                    = var.db_username
  password                    = var.db_password
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.admin_db.id]

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
  description              = "Allow access to admin database from app containers"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.admin_db.id
  cidr_blocks              = var.private_subnets_cidr_blocks
}