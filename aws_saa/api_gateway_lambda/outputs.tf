output "api_gateway_domain" {
  value       = module.api_gateway.aws_api_gateway_invoke_url
  description = "The url of api gateway"
}

output "s3_domain" {
  value       = module.s3.aws_s3_bucket_url
  description = "The url of s3 bucket"
}
