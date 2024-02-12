output "url" {
  value       = aws_lightsail_container_service.sns_service.url
  description = "url of container service"
}

output "db_fqdn" {
  value       = aws_lightsail_database.sns_db.master_endpoint_address
  description = "FQDN of database"
}
