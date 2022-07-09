resource "aws_acm_certificate" "mysite" {
  domain_name = var.domainName

  # cloudfront に対する証明書は virginia リージョンであることが必要
  # see: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html
  provider = "aws.virginia"

  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Environment = "My CloudFront"
  }
}

resource "aws_route53_record" "cert_validation" {
  provider = "aws.virginia"

  allow_overwrite = true
  name            = tolist(aws_acm_certificate.mysite.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.mysite.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.mysite.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.public.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert" {
  provider = "aws.virginia"

  certificate_arn         = aws_acm_certificate.mysite.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
