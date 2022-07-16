output "s3_domain" {
  value       = "https://${module.s3.aws_s3_bucket_domain_name}"
  description = "The url of s3 bucket"
}

output "cloud_front_domain" {
  value       = "https://${module.cloud_front.cloud_front_domain}"
  description = "The url of cloud-front and you should access this URL"
}

output "dynamodb_table_name" {
  value       = module.dynamodb.employee_list_table.name
  description = "The main db table name"
}
