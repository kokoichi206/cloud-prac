resource "aws_acm_certificate" "example" {
  domain_name = aws_route53_record.example.name
  # subject_alternative_names = []
  subject_alternative_names = ["api.${aws_route53_record.example.name}"]
  validation_method         = "DNS"

  # lifecycle は全てのリソースに設定可能。
  # 通常は「削除 → 作成」の流れであるが、証明書の場合は逆の方が良き。
  lifecycle {
    create_before_destroy = true
  }
}

# 検証用の DNS レコード
resource "aws_route53_record" "example_certificate" {
  name    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
  zone_id = data.aws_route53_zone.example.id
  ttl     = 60
}

# 検証の待機
resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_certificate.fqdn]
}
