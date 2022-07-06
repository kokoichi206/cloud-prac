resource "aws_acm_certificate" "main" {
  domain_name               = aws_route53_record.main.name
  subject_alternative_names = ["api.${aws_route53_record.main.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 検証用の DNS レコード
resource "aws_route53_record" "main_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  zone_id = data.aws_route53_zone.main.id
  ttl     = 60
}

# 検証の待機
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.main_certificate : record.fqdn
  ]
}
