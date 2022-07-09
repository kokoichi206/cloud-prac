data "aws_route53_zone" "public" {
  name         = var.domainName
  private_zone = false
}

resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.public.id
  name    = var.domainName

  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.static-www.domain_name
    zone_id                = aws_cloudfront_distribution.static-www.hosted_zone_id
    evaluate_target_health = false
  }
}

output "route53_domain" {
  value = aws_route53_record.web.name
}
