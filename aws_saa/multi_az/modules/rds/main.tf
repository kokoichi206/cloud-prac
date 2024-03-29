resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.20"
  instance_class         = "db.t2.micro"
  identifier             = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name

  multi_az = true
  # Backups are required in order to create a replica
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 1
}

resource "aws_db_instance" "rds-read" {
  allocated_storage   = 10
  storage_type        = "gp2"
  instance_class      = "db.t2.micro"
  identifier          = "${var.db_name}-read"
  replicate_source_db = aws_db_instance.rds.identifier

  # Username and password must not be set for replicas
  password = ""

  backup_retention_period = 0
}

resource "aws_db_subnet_group" "rds-subnet-group" {
  name        = var.prefix
  description = "rds subnet group for ${var.db_name}"
  subnet_ids  = var.pri_subnet_ids
}

resource "aws_security_group" "rds-sg" {
  name        = "${var.prefix}-rds-sg"
  description = "RDS service security group for ${var.prefix}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-rds-sg"
  }
}
