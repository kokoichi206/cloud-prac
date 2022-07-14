output "s3_domain" {
  value       = module.s3.aws_s3_bucket_url
  description = "The url of s3 bucket"
}
