# ホストゾーンの参照
data "aws_route53_zone" "example" {
  name = "kokoichi.link"
}

# 新規ホストゾーンの作成: サブドメイン登録？
resource "aws_route53_zone" "test_example" {
  name = "test.kokoichi.link"
}

# DNSレコード
resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = data.aws_route53_zone.example.name
  type    = "A"

  # 指定したドメインへのアクセスで、ALBへとアクセスできるようにする
  alias {
    name                   = aws_lb.example.dns_name
    zone_id                = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = aws_route53_record.example.name
}
