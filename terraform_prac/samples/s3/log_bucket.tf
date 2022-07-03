resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-programatic-terraform"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}
