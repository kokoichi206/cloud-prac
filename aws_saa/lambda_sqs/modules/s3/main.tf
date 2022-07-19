locals {
  # cannot use underscore(_) as a s3 bucket name
  formatted_prefix = replace(var.prefix, "_", "-")
  bucket_name      = "my-${local.formatted_prefix}-${var.env}-env-bucket"
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = "My bucket for ${var.prefix}"
    Environment = var.env
  }
}
