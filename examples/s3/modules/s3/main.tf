variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

locals {
  # cannot use underscore(_) as a s3 bucket name
  formatted_prefix = replace(var.prefix, "_", "-")
  bucket_name      = "kokoichi-awesome-bucket"
}

resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "versioning_main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "aws_s3_bucket_url" {
  value = "https://${aws_s3_bucket.main.bucket_domain_name}"
}
