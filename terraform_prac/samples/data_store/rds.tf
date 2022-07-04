resource "aws_db_parameter_group" "example" {
  name   = "example"
  family = "mysql5.7"

  parameter {
    name = "character_set_database"
    # MySQL の utf8 は真の utf8 ではなく utf8mb3 を参照している
    # 寿司ビール問題
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_option_group" "example" {
  name                 = "example"
  engine_name          = "mysql"
  major_engine_version = "5.7"

  # mariadb 監査プラグイン
  # https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/Appendix.MySQL.Options.AuditPlugin.html
  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
  }
}

# DB が稼働するサブネット
resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

# DB インスタンス！
## 何回もバージョン書いてる気がするけど、もっと簡潔にできないのかな？
## aws rds modify-db-instance --db-instance-identifier 'example' --master-user-password 'NewMasterPassword!'
resource "aws_db_instance" "example" {
  identifier                 = "example"
  engine                     = "mysql"
  engine_version             = "5.7.25"
  instance_class             = "db.t3.small"
  allocated_storage          = 20
  max_allocated_storage      = 100   # この値まで自動的にスケールする
  storage_type               = "gp2" # 汎用 SSD
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.example.arn
  username                   = "admin"
  password                   = "CorrectPasswordShouldNotBeWrittenHere"
  multi_az                   = true
  publicly_accessible        = false
  backup_window              = "09:10-09:40" # 毎日の定期バックアップ（UTC！）
  backup_retention_period    = 30            # バックアップ期間
  maintenance_window         = "mon:10:10-mon:10:40"
  auto_minor_version_upgrade = false
  deletion_protection        = true
  skip_final_snapshot        = false
  port                       = 3306
  apply_immediately          = false
  vpc_security_group_ids     = [module.mysql_sg.security_group_id]
  parameter_group_name       = aws_db_parameter_group.example.name
  option_group_name          = aws_db_option_group.example.name
  db_subnet_group_name       = aws_db_subnet_group.example.name

  lifecycle {
    ignore_changes = [password]
  }
}

module "mysql_sg" {
  source      = "./security_group"
  name        = "mysql-sg"
  vpc_id      = aws_vpc.example.id
  port        = 3306
  cidr_blocks = [aws_vpc.example.cidr_block]
}
