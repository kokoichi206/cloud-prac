locals {
  # cannot use underscore(_) as a s3 bucket name
  formatted_prefix = replace(var.prefix, "_", "-")
  bucket_name      = "my-${local.formatted_prefix}-${var.env}-env-bucket"
}

resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
  policy = data.aws_iam_policy_document.s3_bucket_policy.json

  force_destroy = true

  tags = {
    Name        = "My bucket for ${var.prefix} of ${var.env}"
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "versioning_main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}
