provider "random" {}

resource "random_string" "password" {
  length = 32
  # DBインスタンスのマスターパスワードでは一部の特殊文字が使えないため、
  # special を false にして特殊文字を制御する！
  special = false
}

# 使用例
resource "aws_db_instance" "exxample" {
  engine              = "mysql"
  instance_class      = "db.t3.small"
  allocated_storage   = 20
  skip_final_snapshot = true
  username            = "admin"
  password            = random_string.password.result
}
