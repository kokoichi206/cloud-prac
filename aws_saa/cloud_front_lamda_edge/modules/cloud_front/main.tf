resource "aws_cloudfront_origin_access_identity" "static-www" {}

resource "aws_cloudfront_distribution" "static-www" {
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = var.bucket_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static-www.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

      query_string_cache_keys = [
        "name"
      ]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    lambda_function_association {
      event_type = "viewer-request"
      # lambda_arn = var.qualified_lambda_arn
      lambda_arn   = "${var.qualified_lambda_arn}:${var.lambda_version}"
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # none でも locations がないとエラーになる
      locations = []
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
