resource "aws_kms_key" "example" {
  description             = "Example Customer Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

# 人間が識別しやすくするためのエイリアス
resource "aws_key_alias" "example" {
  # alias/ prefix が必要
  name = "alias/example"
  target_key_id = aws_kms_key.example.key_id
}
