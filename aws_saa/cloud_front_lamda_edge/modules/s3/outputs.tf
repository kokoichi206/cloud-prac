output "bucket_id" {
  value       = aws_s3_bucket.main.id
  description = "bucket id"
}

output "aws_s3_bucket_domain_name" {
  value       = aws_s3_bucket.main.bucket_domain_name
  description = "the domain name of s3 bucket"
}
