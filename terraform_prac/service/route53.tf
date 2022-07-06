# ホストゾーンの参照
data "aws_route53_zone" "main" {
  name = "kokoichi.link"
}

# 新規ホストゾーンの作成: サブドメイン登録？
resource "aws_route53_zone" "main_api" {
  name = "api.kokoichi.link"
}

# DNSレコード
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = data.aws_route53_zone.main.name
  type    = "A"

  # 指定したドメインへのアクセスで、ALBへとアクセスできるようにする
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

output "domain_name" {
  value = aws_route53_record.main.name
}
