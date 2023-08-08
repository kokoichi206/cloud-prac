variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

locals {
  # cannot use underscore(_) as a s3 bucket name
  formatted_prefix = replace(var.prefix, "_", "-")
  bucket_name      = "minio-compatibility-test"
}

resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
  acl = "private"

  lifecycle_rule {
    id      = "gracier_3d"
    enabled = true

    transition {
      days          = 2
      # storage class
      # see: https://docs.aws.amazon.com/AmazonS3/latest/API/API_Transition.html#AmazonS3-Type-Transition-StorageClass
      storage_class = "GLACIER"
    }
  }
}

output "aws_s3_bucket_url" {
  value = "https://${aws_s3_bucket.main.bucket_domain_name}"
}
