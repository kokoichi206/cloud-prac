resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.current.id]
      # identifiers = ["582318560864"]
    }
  }
}

resource "aws_s3_bucket" "alb_log" {
  bucket = "alb-log-programatic-terraform-kokoichi"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_s3_bucket" "public" {
  bucket = "aws-s3-bucket-kokoichi-public"
  acl    = "public-read"

  cors_rule {
    allowed_origins = ["http://kokoichi.link/"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
