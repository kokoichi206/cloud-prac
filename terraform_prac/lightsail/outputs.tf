output "backend_url" {
  value       = module.lightsail.url
  description = "url of backend service"
}

output "database_fqdn" {
  value       = module.lightsail.db_fqdn
  description = "FQDN of backend database"
}
