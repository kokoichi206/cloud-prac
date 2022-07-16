# for another module
output "cloud_front_arn" {
  value       = aws_cloudfront_distribution.static-www.arn
  description = "arn of cloud front"
}

# for main outputs
output "cloud_front_domain" {
  value       = aws_cloudfront_distribution.static-www.domain_name
  description = "the domain name of cloud front"
}
