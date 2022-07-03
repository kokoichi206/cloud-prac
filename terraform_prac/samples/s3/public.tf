resource "aws_s3_bucket" "publi" {
  bucket = "test-test-test"
  acl    = "public-read"

  cors_rule {
    allowed_origins = ["https://hogehoge.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
