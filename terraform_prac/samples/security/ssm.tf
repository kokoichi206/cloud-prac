# 平文で保存
resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "root"
  type        = "String"
  description = "DBのユーザー名"
}

# 暗号化して保存
resource "aws_ssm_parameter" "db_raw_password" {
  name = "/db/raw_password"
  # このように値を埋め込むべきではない！
  # Terraform ではダミー値を設定し、後から AWS CLI で更新する
  # aws ssm ...
  value       = "password"
  type        = "SecureString"
  description = "DBのパスワード"

  lifecycle {
    ignore_changes = [value]
  }
}
