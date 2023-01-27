# Add RDS database instance subnet group
resource "aws_db_subnet_group" "database" {
  name       = "${var.name}-${var.environment_type}-db-subnet-group"
  subnet_ids = [aws_subnet.rds01.id, aws_subnet.rds02.id]
}

# Create a random_password resource for the RDS Instance
resource "random_password" "database_password" {
  length  = 16
  special = false
}

# Create RDS database instance
resource "aws_db_instance" "database" {
  allocated_storage      = var.database_allocated_storage
  db_name                = var.database_name
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  instance_class         = var.database_instance_class
  username               = var.database_username
  password               = random_password.database_password.result
  parameter_group_name   = var.database_parameter_group
  db_subnet_group_name   = aws_db_subnet_group.database.name
  skip_final_snapshot    = var.database_skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  tags                   = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-rds" }))
}