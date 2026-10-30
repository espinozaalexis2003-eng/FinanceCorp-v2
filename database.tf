# Keep RDS disabled until testing
variable "enable_database" {
  description = "Deploy FinanceCorp PostgreSQL database"
  type        = bool
  default     = false
}

# Private DB subnet group
resource "aws_db_subnet_group" "financecorp" {
  name = "financecorp-v2-db-subnets"

  subnet_ids = [
    aws_subnet.db_a.id,
    aws_subnet.db_b.id
  ]

  tags = {
    Name    = "FinanceCorp-v2-DB-Subnet-Group"
    Project = "FinanceCorp-v2"
  }
}

# PostgreSQL RDS database
resource "aws_db_instance" "financecorp" {
  count = var.enable_database ? 1 : 0

  identifier = "financecorp-v2-db"

  engine         = "postgres"
  engine_version = "17"

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 0
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "financecorp"
  username = "financecorp_admin"

  # RDS manages the master password in Secrets Manager
  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.financecorp.name

  vpc_security_group_ids = [
    aws_security_group.db.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true

  apply_immediately = true

  tags = {
    Name    = "FinanceCorp-v2-PostgreSQL"
    Project = "FinanceCorp-v2"
  }
}