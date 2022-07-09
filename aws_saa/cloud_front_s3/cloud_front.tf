resource "aws_cloudfront_origin_access_identity" "static-www" {}

resource "aws_cloudfront_distribution" "static-www" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static-www.cloudfront_access_identity_path
    }
  }

  enabled = true

  default_root_object = "index.html"
  aliases             = [var.domainName]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # 配信制限
  restrictions {
    geo_restriction {
      restriction_type = "none"
      # none でも locations がないとエラーになる
      locations = []
    }
  }
  # 独自証明書を使うよう変更
  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = aws_acm_certificate.mysite.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }
}

output "cloud_ftont_domain" {
  value = aws_cloudfront_distribution.static-www.domain_name
}
